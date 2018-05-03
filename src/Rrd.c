#include <rrd.h>
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>
#include <stdio.h>




//demonstrates how c arrays are imported in R
// SEXP exposeArray(char c){
//   int array[5] = {1,2,3,4,5};
//   int size = sizeof (array) / sizeof (*array);
//   SEXP out = PROTECT(allocVector(INTSXP, size));
//   for (int i = 0; i < size; i++){
//     // printf("iterating.. i = %d len = %d\n", i, size);
//     INTEGER(out)[i] = array[i];
//   }
//   UNPROTECT(1);
//   
//   return out;
// }


/*A wrapper for rrd_fetch_r*/
/*Finds the RRA of interest that best matches cfIn, and stepIn in filenameIn*/
/*then returns an R data.frame that contain the RRA values fitting between timestamps startIn (non incl) and sendIn*/
SEXP importRRD(SEXP filenameIn, SEXP cfIn, SEXP startIn, SEXP endIn, SEXP stepIn)  {
  
  rrd_value_t *data;
  
  const char *filename;
  const char *cf;
  char** ds_namv = NULL;
  
  time_t start;
  time_t end;
  
  unsigned long step;
  unsigned long ds_cnt;
  
  int status;
  int size;
  int ds;
  int i;
  int timeStamp;
  
  SEXP out;
  SEXP vec;
  SEXP nam;
  SEXP rowNam;
  SEXP cls;
  
  filename  = CHAR(asChar(filenameIn));
  
  if (access(filename, F_OK) == -1) {
    // printf("file does not exist\n");
    return R_NilValue;
  }
  
  cf = CHAR(asChar(cfIn));
  start = (time_t) asInteger(startIn);
  end = (time_t) asInteger(endIn);
  
  step  = (unsigned long) asInteger(stepIn);
  
  
  
  //calling rrdfetch
  
  status = rrd_fetch_r(filename, cf, &start, &end, &step, &ds_cnt, &ds_namv, &data);
  if (status != 0 || data == NULL) {
    // printf("error running rrd_fetch_r\n");
    //rrd_fetch_r is supposed to free ds_namv
    //doesn't set to NULL so can't do checks here
    
    if (data)
      free(data);
    return R_NilValue;
  }
  
  // printf("size of data %d start %d end %d step %d ds_cnt %d\n", sizeof(data)/sizeof(rrd_value_t), start, end, step, ds_cnt);
  
  //turns out rrd_fetch does not include start in data
  size = (end - start)/step - 1;
  
  out = PROTECT(allocVector(VECSXP, ds_cnt + 1) );
  
  vec = PROTECT(allocVector(INTSXP, size));
  PROTECT(rowNam = allocVector(STRSXP, size));
  
  //turns out rrd_fetch does not include start in data
  timeStamp = start + step;
  
  for (i = 0; i < size; i++) {
    INTEGER(vec)[i] = timeStamp;
    
    timeStamp += step;
    
  }
  SET_VECTOR_ELT(out, 0, vec);
  setAttrib(out, R_RowNamesSymbol, vec);
  
  PROTECT(nam = allocVector(STRSXP, ds_cnt + 1));
  SET_STRING_ELT(nam, 0, mkChar("timestamp"));
  
  
  for (ds = 0; ds < ds_cnt; ds++){
    SET_STRING_ELT(nam, ds + 1, mkChar(ds_namv[ds]));
    
    vec = PROTECT(allocVector(REALSXP, size));
    for (i = 0; i < size; i++){
      /*// printf("iterating.. i = %d\n", i);*/
      REAL(vec)[i] = data[ds + i*ds_cnt];
    }
    SET_VECTOR_ELT(out, ds + 1, vec);
  }
  
  PROTECT(cls = allocVector(STRSXP, 1)); // class attribute
  SET_STRING_ELT(cls, 0, mkChar("data.frame"));
  classgets(out, cls);
  namesgets(out, nam);
  
  
  
  
  free(data);
  for (int k = 0; k < sizeof(ds_namv)/sizeof(char*); k++) {
    free(ds_namv[k]);
  }
  free(ds_namv);
  
  UNPROTECT(ds_cnt + 5);
  
  return out;
  
  
}


//linked list we use to store the rra info
typedef struct _rraInfo {
  char cf[80];
  unsigned long rows;
  unsigned long perRow;
  struct _rraInfo* next;
} rraInfo; 


void freeRraInfo(rraInfo* rraInfoOut) {
  while (rraInfoOut) {
    rraInfo* tmp = rraInfoOut;
    rraInfoOut = rraInfoOut->next;
    free(tmp);
    
  }
  rraInfoOut = NULL;
}

void printRraInfo(rraInfo* rraInfoIn) {
  
  rraInfo* rraInfoTmp = rraInfoIn;
  
  while (rraInfoTmp) {
    
    // printf("rows %d\n", rraInfoTmp->rows);
    // printf("perRow %d\n", rraInfoTmp->perRow);
    // printf("cf %s\n", rraInfoTmp->cf);
    
    rraInfoTmp = rraInfoTmp->next;
    
  }
}

/*reads a rrd_info_t returned by rrdinfo and */
/*returns the information we need in a rraInfo linked list*/
/*returns the rra count and the global step by reference*/
rraInfo* getRraInfo (rrd_info_t* rrdInfoIn, int *rraCntOut, unsigned long *stepOut){
  unsigned long step = 0;
  int rraCnt = 0;
  
  char cfKey[80];
  char rowsKey[80];
  char perRowKey[80];
  
  //generating key values
  sprintf(cfKey, "rra[%d].cf", 0);
  sprintf(rowsKey, "rra[%d].rows", 0);
  sprintf(perRowKey, "rra[%d].pdp_per_row", 0);
  
  
  rraInfo* rraInfoOut;
  rraInfo* rraInfoTmp;
  
  rraInfoOut = malloc(sizeof(rraInfo)); 
  if (rraInfoOut == NULL) {
    // printf("error allocating memory\n");
    return NULL;
  }
  
  rraInfoTmp = rraInfoOut;
  
  
  
  //note this assumes the entries in rrdInfoIn are in a certain order!
  //looking at the code of rrdinfo I think we can safely assume this
  while(rrdInfoIn) {
    
    if (!strcmp(rrdInfoIn->key, "step")){
      step = rrdInfoIn->value.u_cnt;
    }
    
    
    if (!strcmp(rrdInfoIn->key, cfKey)){
      
      if (rraCnt > 0) {
        
        rraInfoTmp->next = malloc(sizeof(rraInfo));
        if (rraInfoTmp->next == NULL) {
          freeRraInfo(rraInfoOut);
          return NULL;
        }
        
        
        rraInfoTmp = rraInfoTmp->next;
        rraInfoTmp->next = NULL;
      }
      
      //copying cf string
      strcpy(rraInfoTmp->cf, rrdInfoIn->value.u_str);
      
    }
    
    if (!strcmp(rrdInfoIn->key, rowsKey)){
      // printf("matching rowsKey\n");
      rraInfoTmp->rows = rrdInfoIn->value.u_cnt;
      
    }
    
    if (!strcmp(rrdInfoIn->key, perRowKey)){
      // printf("matching perRowKey\n");
      rraInfoTmp->perRow = rrdInfoIn->value.u_cnt;
      rraCnt++;
      
      //generate keys for next RRA
      sprintf(cfKey, "rra[%d].cf", rraCnt);
      sprintf(rowsKey, "rra[%d].rows", rraCnt);
      sprintf(perRowKey, "rra[%d].pdp_per_row", rraCnt);
      
    }
    
    
    rrdInfoIn = rrdInfoIn->next;
  }
  
  if (rraCnt == 0) {
    free(rraInfoOut);
    rraInfoOut = NULL;
  }
  
  
  *rraCntOut = rraCnt;
  *stepOut = step;
  
  return rraInfoOut;
}


/*A wrapper for rrd_fetch_r that first gets some information for the RRD*/
/*and uses that information to expose all values in the file*/

/*Returns a list (one for each RRA) of R data.frames  */
/*gets the cosolidation functions and computes the step for each RRA*/
/*gets the first and last timestamp for each RRA*/
/*calls rrd_fetch_r and copies all values to R data frames*/

SEXP smartImportRRD(SEXP filenameIn){
  
  time_t first;
  time_t last;
  time_t start;
  time_t end;
  
  time_t *startAr;
  
  
  unsigned long curStep;
  unsigned long ds_cnt;
  unsigned long step;
  
  int rraCnt;
  int status;
  int size;
  int i;
  int ds;
  int j;
  int timeStamp;
  
  char **ds_namv;
  const char *filename;
  
  rrd_value_t *data;
  
  rraInfo* rraInfoList;
  rraInfo* rraInfoTmp;
  
  rrd_info_t *rrdInfo;
  
  
  SEXP out;
  SEXP vec;
  SEXP rraSexpList; 
  SEXP rraNames;
  SEXP nam;
  SEXP rowNam;
  SEXP cls;
  
  
  filename  = CHAR(asChar(filenameIn));
  if (access(filename, F_OK) == -1) {
    // printf("file does not exist\n");
    return R_NilValue;
  }
  
  
  //getting last time stamp
  last = rrd_last_r(filename);
  
  
  //getting rrd info
  rrdInfo = rrd_info_r(filename);
  
  if (rrdInfo == NULL) {
    // printf("getting rrd info failed");
    return R_NilValue;
  }
  
  
  //obtain linked list containing the parameters for each RRA
  rraInfoList = getRraInfo(rrdInfo, &rraCnt, &step);
  
  if (rraInfoList == NULL) {
    // printf("getting rra info failed\n");
    free(rrdInfo);
    return R_NilValue;
    
  }
  
  printRraInfo(rraInfoList);
  
  
  startAr = malloc(rraCnt * sizeof(time_t));
  
  if (startAr == NULL) {
    // printf("memory allocation error");
    free(rrdInfo);
    freeRraInfo(rraInfoList);
    return R_NilValue;
  }
  
  
  
  //getting first timestamp for each RRA
  for (i = 0; i < rraCnt; i++) {
    startAr[i] = rrd_first_r(filename, i);
  }
  
  
  rraInfoTmp = rraInfoList;
  PROTECT(rraNames = allocVector(STRSXP, rraCnt));
  
  PROTECT(cls = allocVector(STRSXP, 1));
  SET_STRING_ELT(cls, 0, mkChar("data.frame"));
  
  
  out = PROTECT(allocVector(VECSXP, rraCnt));
  
  i = 0;
  
  //processing each RRA
  while (rraInfoTmp) {
    
    start = startAr[i];
    end = last;
    curStep = step * rraInfoTmp->perRow;
    
    
    status = rrd_fetch_r(filename, rraInfoTmp->cf, &start, &end, &curStep, &ds_cnt, &ds_namv, &data);
    
    if (status != 0 || data == NULL) {
      // printf("error running rrd_fetch_r\n");
      free(rrdInfo);
      freeRraInfo(rraInfoList);
      free(startAr);
      if (data)
        free(data);
      return R_NilValue;
    }
    
    
    //rrd_fetch does not include start
    size = (end - start)/curStep - 1;
    // printf("size %d\n", size);
    
    rraSexpList = PROTECT(allocVector(VECSXP, ds_cnt + 1));
    
    vec = PROTECT(allocVector(INTSXP, size));
    PROTECT(rowNam = allocVector(STRSXP, size));
    
    //rrd_fetch does not include start
    timeStamp = start + curStep;
    
    
    
    
    for (int j = 0; j < size; j++) {
      INTEGER(vec)[j] = timeStamp;
      timeStamp += curStep;
      
    }
    
    //setting row names
    SET_VECTOR_ELT(rraSexpList, 0, vec);
    setAttrib(rraSexpList, R_RowNamesSymbol, vec);
    
    PROTECT(nam = allocVector(STRSXP, ds_cnt + 1));
    SET_STRING_ELT(nam, 0, mkChar("timestamp"));
    
    
    //populating data frames with data
    for (ds = 0; ds < ds_cnt; ds++){
      SET_STRING_ELT(nam, ds + 1, mkChar(ds_namv[ds]));
      vec = PROTECT(allocVector(REALSXP, size));
      
      for (j = 0; j < size; j++){
        REAL(vec)[j] = data[ds + j*ds_cnt];
      }
      
      
      
      //adding ds vector to data frame
      SET_VECTOR_ELT(rraSexpList, ds + 1, vec);
    }
    
    classgets(rraSexpList, cls);
    namesgets(rraSexpList, nam);
    
    
    
    //adding data frame to out
    SET_VECTOR_ELT(out, i, rraSexpList);
    
    //generating data frame labels
    char rraNameString[80];
    char stepString[40];
    
    sprintf(stepString, "%d", curStep);
    strcpy(rraNameString, rraInfoTmp->cf);
    strcat(rraNameString, stepString);
    SET_STRING_ELT(rraNames, i, mkChar(rraNameString));
    
    
    rraInfoTmp = rraInfoTmp->next;
    
    i++;
    free(data);
  }
  
  setAttrib(out, R_NamesSymbol, rraNames);
  
  
  freeRraInfo(rraInfoList);
  free(startAr);
  free(rrdInfo);
  for (int k = 0; k < sizeof(ds_namv)/sizeof(char*); k++) {
    free(ds_namv[k]);
  }
  free(ds_namv);
  
  UNPROTECT((ds_cnt + 4)*rraCnt + 3);
  
  
  return out;
  
}

/* gets the first timestamp for the RRA identified by cfIn and stepIn in filenameIn */
SEXP getFirst(SEXP filenameIn, SEXP cfIn, SEXP stepIn)  {
  const char *filename;
  const char *cf;
  
  unsigned long step;
  unsigned long curStep;
  
  rrd_info_t *rrdInfo;
  
  rraInfo* rraInfoList;
  rraInfo* rraInfoTmp;
  
  int i;
  int rraCnt;
  
  SEXP out;
  
  filename  = CHAR(asChar(filenameIn));
  
  if (access(filename, F_OK) == -1) {
    // printf("file does not exist\n");
    return R_NilValue;
  }
  
  cf = CHAR(asChar(cfIn));
  
  curStep  = (unsigned long) asInteger(stepIn);
  rrdInfo = rrd_info_r(filename);
  
  if (rrdInfo == NULL) {
    // printf("error getting rrd info");
    return R_NilValue;
  }
  
  
  rraInfoList = getRraInfo(rrdInfo, &rraCnt, &step);
  
  if (rraInfoList == NULL) {
    // printf("error getting rrd info");
    free(rrdInfo);
    return R_NilValue;
    
  }
  
  rraInfoTmp = rraInfoList;
  
  i = 0;
  while (rraInfoTmp) {
    if (!strcmp(cf, rraInfoTmp->cf) && (curStep == step*rraInfoTmp->perRow)) {
      break;
    }
    i++;
    rraInfoTmp = rraInfoTmp->next;
  }
  
  out = PROTECT(allocVector(INTSXP, 1));
  if (i < rraCnt) {
    INTEGER(out)[0] = rrd_first_r(filename, i);
  } else {
    out = R_NilValue;
  }
  
  freeRraInfo(rraInfoList);
  free(rrdInfo);
  UNPROTECT(1);
  
  
  return out;
  
}
