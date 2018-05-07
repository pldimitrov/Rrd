#include <rrd.h>
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>
#include <stdio.h>


// demonstrates how c arrays are imported in R
//
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

// linked list we use to store the rra info
typedef struct _rra_info {
  char cf[80];
  unsigned long rows;
  unsigned long pdp_per_row;
  struct _rra_info* next;
} rra_info; 


void free_rra_info(rra_info* rraInfoOut) {
  while (rraInfoOut) {
    rra_info* tmp = rraInfoOut;
    rraInfoOut = rraInfoOut->next;
    free(tmp);
  }
  rraInfoOut = NULL;
}


void print_rra_info(rra_info* rraInfoIn, int count, long unsigned int step) {
  long unsigned int pdp_per_row;
  int i;
  long unsigned int rra_step;
  
  Rprintf("A RRD file with %d RRA arrays and step size %ld\n", count, step);
  
  rra_info* rra_info_tmp = rraInfoIn;
  i = 1;
  while (rra_info_tmp) {
    pdp_per_row = rra_info_tmp->pdp_per_row;
    rra_step = step * pdp_per_row;
    
    Rprintf("[%d] %s_%ld (%ld rows)\n", i, rra_info_tmp->cf, rra_step, rra_info_tmp->rows);
    
    /*
    Rprintf("- cf: %s\n", rra_info_tmp->cf);
    Rprintf("- step: %ld\n", rra_step);
    Rprintf("- rows  : %ld\n", rra_info_tmp->rows);
    Rprintf("- pdp_per_row: %ld\n", pdp_per_row);
     */
    
    rra_info_tmp = rra_info_tmp->next;
    i++;
  }
}


/* reads a rrd_info_t returned by rrdinfo and 
 * returns the information we need in a rra_info linked list 
 * returns the rra count and the global step by reference
 */
rra_info* get_rra_info(rrd_info_t* rrdInfoIn, int *rraCntOut, unsigned long *stepOut){
  unsigned long step = 0;
  int rraCnt = 0;
  
  char cfKey[80];
  char rowsKey[80];
  char perRowKey[80];
  
  //generating key values
  sprintf(cfKey, "rra[%d].cf", 0);
  sprintf(rowsKey, "rra[%d].rows", 0);
  sprintf(perRowKey, "rra[%d].pdp_per_row", 0);
  
  rra_info* rraInfoOut;
  rra_info* rra_info_tmp;
  
  rraInfoOut = malloc(sizeof(rra_info)); 
  if (rraInfoOut == NULL) {
    Rprintf("error allocating memory\n");
    return NULL;
  }
  
  rra_info_tmp = rraInfoOut;
  
  // note this assumes the entries in rrdInfoIn are in a certain order!
  // looking at the code of rrdinfo I think we can safely assume this
  while(rrdInfoIn) {
    
    if (!strcmp(rrdInfoIn->key, "step")){
      step = rrdInfoIn->value.u_cnt;
    }
    
    if (!strcmp(rrdInfoIn->key, cfKey)){
      if (rraCnt > 0) {
        rra_info_tmp->next = malloc(sizeof(rra_info));
        if (rra_info_tmp->next == NULL) {
          free_rra_info(rraInfoOut);
          return NULL;
        }
        rra_info_tmp = rra_info_tmp->next;
        rra_info_tmp->next = NULL;
      }
      //copying cf string
      strcpy(rra_info_tmp->cf, rrdInfoIn->value.u_str);
    }
    
    if (!strcmp(rrdInfoIn->key, rowsKey)){
      // printf("matching rowsKey\n");
      rra_info_tmp->rows = rrdInfoIn->value.u_cnt;
    }
    
    if (!strcmp(rrdInfoIn->key, perRowKey)){
      // printf("matching perRowKey\n");
      rra_info_tmp->pdp_per_row = rrdInfoIn->value.u_cnt;
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


/* gets the first timestamp for the RRA identified by cfIn and stepIn in filenameIn  
 * 
 */
SEXP get_first(SEXP filenameIn, SEXP cfIn, SEXP stepIn)  {
  const char *cf;
  
  unsigned long step;
  unsigned long curStep;
  
  rrd_info_t *rrdInfo;
  
  rra_info* rra_info_list;
  rra_info* rra_info_tmp;
  
  int i;
  int rraCnt;
  
  SEXP out;
  
  char *filename = (char *)CHAR(asChar(filenameIn));
  
  if (access(filename, F_OK) == -1) {
    Rprintf("file does not exist\n");
    return R_NilValue;
  }
  
  cf = CHAR(asChar(cfIn));
  
  curStep  = (unsigned long) asInteger(stepIn);
  rrdInfo = rrd_info_r(filename);
  
  if (rrdInfo == NULL) {
    Rprintf("error getting rrd info");
    return R_NilValue;
  }
  
  rra_info_list = get_rra_info(rrdInfo, &rraCnt, &step);
  
  if (rra_info_list == NULL) {
    Rprintf("error getting rrd info");
    free(rrdInfo);
    return R_NilValue;
  }
  
  rra_info_tmp = rra_info_list;
  
  i = 0;
  while (rra_info_tmp) {
    if (!strcmp(cf, rra_info_tmp->cf) && (curStep == step * rra_info_tmp->pdp_per_row)) {
      break;
    }
    i++;
    rra_info_tmp = rra_info_tmp->next;
  }
  
  out = PROTECT(allocVector(INTSXP, 1));
  if (i < rraCnt) {
    INTEGER(out)[0] = rrd_first_r(filename, i);
  } else {
    out = R_NilValue;
  }
  
  free_rra_info(rra_info_list);
  free(rrdInfo);
  UNPROTECT(1);
  
  return out;
}


/* describe the contents of an RRD
 * 
 */
SEXP describe_rrd(SEXP filenameIn){
  
  int rraCnt, status, size, i, ds, j, timeStamp;
  unsigned long curStep, n_datasets, step;
  rra_info* rra_info_list;
  rrd_info_t *rrdInfo;
  
  char *filename = (char *)CHAR(asChar(filenameIn));
  
  //getting rrd info
  rrdInfo = rrd_info_r(filename);
  
  if (rrdInfo == NULL) {
    error("getting rrd info failed");
  }
  
  //obtain linked list containing the parameters for each RRA
  rra_info_list = get_rra_info(rrdInfo, &rraCnt, &step);
  
  if (rra_info_list == NULL) {
    free(rrdInfo);
    error("getting rra info failed\n");
  }
  
  print_rra_info(rra_info_list, rraCnt, step);
  
  free_rra_info(rra_info_list);
  free(rrdInfo);
  
  return(R_NilValue);
}



/* A wrapper for rrd_fetch_r that first gets some information for the RRD
 * and uses that information to expose all values in the file
 * 
 * Returns a list (one for each RRA) of R data.frames
 * gets the cosolidation functions and computes the step for each RRA
 * gets the first and last timestamp for each RRA
 * calls rrd_fetch_r and copies all values to R data frames
 * 
 * https://github.com/oetiker/rrdtool-1.x/blob/master/src/rrd_fetch.c
 */
SEXP smart_import_rrd(SEXP filenameIn){
  
  int rraCnt, status, size, i, ds, j, timeStamp;
  unsigned long curStep, n_datasets, step;
  char **ds_namv; // names of data sources
  // char *filename;
  
  time_t first, last, start, end, *startAr;
  rrd_value_t *data;
  rra_info* rra_info_list;
  rra_info* rra_info_tmp;
  rrd_info_t *rrdInfo;
  
  SEXP out, vec, rraSexpList, rraNames, nam, rowNam, cls;
  
  char *filename = (char *)CHAR(asChar(filenameIn));

  //getting last time stamp
  last = rrd_last_r(filename);
  
  //getting rrd info
  rrdInfo = rrd_info_r(filename);
  
  if (rrdInfo == NULL) {
    error("getting rrd info failed");
  }
  
  //obtain linked list containing the parameters for each RRA
  rra_info_list = get_rra_info(rrdInfo, &rraCnt, &step);
  
  if (rra_info_list == NULL) {
    free(rrdInfo);
    error("getting rra info failed\n");
  }
  
  //print_rra_info(rra_info_list, &rraCnt, &step);
  
  startAr = malloc(rraCnt * sizeof(time_t));
  
  if (startAr == NULL) {
    free(rrdInfo);
    free_rra_info(rra_info_list);
    error("memory allocation error");
  }
  
  //getting first timestamp for each RRA
  for (i = 0; i < rraCnt; i++) {
    startAr[i] = rrd_first_r(filename, i);
  }
  
  rra_info_tmp = rra_info_list;
  PROTECT(rraNames = allocVector(STRSXP, rraCnt));
  
  PROTECT(cls = allocVector(STRSXP, 1));
  SET_STRING_ELT(cls, 0, mkChar("data.frame"));
  
  out = PROTECT(allocVector(VECSXP, rraCnt));
  
  i = 0;
  
  // processing each RRA
  while (rra_info_tmp) {
    start = startAr[i];
    end = last;
    curStep = step * rra_info_tmp->pdp_per_row;
    status = rrd_fetch_r(filename, rra_info_tmp->cf, &start, &end, &curStep, &n_datasets, &ds_namv, &data);

    if (status != 0 || data == NULL) {
      Rprintf("error running rrd_fetch_r\n");
      free(rrdInfo);
      free_rra_info(rra_info_list);
      free(startAr);
      if (data)
        free(data);
      return R_NilValue;
    }
    
    // rrd_fetch does not include start
    size = (end - start)/curStep - 1;
    // printf("size %d\n", size);
    
    rraSexpList = PROTECT(allocVector(VECSXP, n_datasets + 1));
    
    vec = PROTECT(allocVector(INTSXP, size));
    PROTECT(rowNam = allocVector(STRSXP, size));
    
    // rrd_fetch does not include start
    timeStamp = start + curStep;
    
    for (int j = 0; j < size; j++) {
      INTEGER(vec)[j] = timeStamp;
      timeStamp += curStep;
    }
    
    // set row names
    SET_VECTOR_ELT(rraSexpList, 0, vec);
    setAttrib(rraSexpList, R_RowNamesSymbol, vec);
    
    PROTECT(nam = allocVector(STRSXP, n_datasets + 1));
    SET_STRING_ELT(nam, 0, mkChar("timestamp"));
    
    // populating data frames with data
    for (ds = 0; ds < n_datasets; ds++){
      SET_STRING_ELT(nam, ds + 1, mkChar(ds_namv[ds]));
      vec = PROTECT(allocVector(REALSXP, size));
      
      for (j = 0; j < size; j++){
        REAL(vec)[j] = data[ds + j * n_datasets];
      }
      // adding ds vector to data frame
      SET_VECTOR_ELT(rraSexpList, ds + 1, vec);
    }
    
    classgets(rraSexpList, cls);
    namesgets(rraSexpList, nam);
    
    //adding data frame to out
    SET_VECTOR_ELT(out, i, rraSexpList);
    
    //generating data frame labels
    char rraNameString[80];
    char stepString[40];
    
    sprintf(stepString, "%ld", curStep);
    strcpy(rraNameString, rra_info_tmp->cf);
    // strcat(rraNameString, "_");
    strcat(rraNameString, stepString);
    SET_STRING_ELT(rraNames, i, mkChar(rraNameString));
    
    rra_info_tmp = rra_info_tmp->next;
    
    i++;
    free(data);
  }
  
  setAttrib(out, R_NamesSymbol, rraNames);
  
  free_rra_info(rra_info_list);
  free(startAr);
  free(rrdInfo);
  for (int k = 0; k < sizeof(ds_namv)/sizeof(char*); k++) {
    free(ds_namv[k]);
  }
  free(ds_namv);
  
  UNPROTECT((n_datasets + 4)*rraCnt + 3);
  
  return out;
}


/* A wrapper for rrd_fetch_r
 * Finds the RRA of interest that best matches cfIn, and stepIn in filenameIn 
 * then returns an R data.frame that contain the RRA values fitting between 
 * timestamps startIn (non incl) and sendIn
 */
SEXP import_rrd(SEXP filenameIn, SEXP cfIn, SEXP startIn, SEXP endIn, SEXP stepIn)  {
  
  rrd_value_t *data;
  
  unsigned long step, n_datasets;
  int status, size, ds, i, timeStamp;
  
  // char *filename;
  // const char *cf;
  char** ds_namv = NULL;
  
  time_t start, end;
  SEXP out, vec, nam, rowNam, cls;
  
  const char *filename  = CHAR(asChar(filenameIn));
  
  const char *cf = CHAR(asChar(cfIn));
  start = (time_t) asInteger(startIn);
  end = (time_t) asInteger(endIn);
  
  step  = (unsigned long) asInteger(stepIn);
  
  // calling rrdfetch
  status = rrd_fetch_r(filename, cf, &start, &end, &step, &n_datasets, &ds_namv, &data);
  if (status != 0 || data == NULL) {
    Rprintf("error running rrd_fetch_r\n");
    // rrd_fetch_r is supposed to free ds_namv
    // doesn't set to NULL so can't do checks here
    if (data)
      free(data);
    return R_NilValue;
  }
  
  // printf("size of data %d start %d end %d step %d n_datasets %d\n", sizeof(data)/sizeof(rrd_value_t), start, end, step, n_datasets);
  
  // turns out rrd_fetch does not include start in data
  size = (end - start)/step - 1;
  out = PROTECT(allocVector(VECSXP, n_datasets + 1) );
  vec = PROTECT(allocVector(INTSXP, size));
  PROTECT(rowNam = allocVector(STRSXP, size));
  
  // turns out rrd_fetch does not include start in data
  timeStamp = start + step;
  
  for (i = 0; i < size; i++) {
    INTEGER(vec)[i] = timeStamp;
    timeStamp += step;
  }
  
  // set row names
  SET_VECTOR_ELT(out, 0, vec);
  setAttrib(out, R_RowNamesSymbol, vec);
  
  // set timestamp columns
  PROTECT(nam = allocVector(STRSXP, n_datasets + 1));
  SET_STRING_ELT(nam, 0, mkChar("timestamp"));
  
  // set all other columns
  for (ds = 0; ds < n_datasets; ds++){
    SET_STRING_ELT(nam, ds + 1, mkChar(ds_namv[ds]));
    
    vec = PROTECT(allocVector(REALSXP, size));
    for (i = 0; i < size; i++){
      /* // printf("iterating.. i = %d\n", i); */
      REAL(vec)[i] = data[ds + i*n_datasets];
    }
    SET_VECTOR_ELT(out, ds + 1, vec);
  }
  
  // set class and names of data frame 
  PROTECT(cls = allocVector(STRSXP, 1)); // class attribute
  SET_STRING_ELT(cls, 0, mkChar("data.frame"));
  classgets(out, cls);
  namesgets(out, nam);
  
  free(data);
  for (int k = 0; k < sizeof(ds_namv)/sizeof(char*); k++) {
    free(ds_namv[k]);
  }
  free(ds_namv);
  UNPROTECT(n_datasets + 5);
  return out;
}


