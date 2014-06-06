#define RRD_EXPORT_DEPRECATED

#include <rrd.h>
//#include <rrd_format.h>
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>
#include <stdio.h>
/*#include "rrd_tool.h"*/
/*#include "rrd_rpncalc.h"*/
/*#include "rrd_client.h"*/



#define RRD_READONLY    (1<<0)
#define RRD_READWRITE   (1<<1)
#define RRD_CREAT       (1<<2)
#define RRD_READAHEAD   (1<<3)
#define RRD_COPY        (1<<4)
#define RRD_EXCL        (1<<5)


SEXP exposeArray(char c){
    int array[5] = {1,2,3,4,5};
    int size = sizeof (array) / sizeof (*array);
    SEXP out = PROTECT(allocVector(INTSXP, size));
    for (int i = 0; i < size; i++){
	printf("iterating.. i = %d len = %d\n", i, size);
	INTEGER(out)[i] = array[i];
    }
    UNPROTECT(1);

    return out;
}

SEXP importRRD(const char* filename){
    rrd_t rrd;
    unsigned int i, ii, ix, iii = 0;
    rrd_file_t *rrd_file;
    rrd_init(&rrd);
    rrd_value_t my_cdp;
    off_t     rra_base, rra_start, rra_next;

    rrd_file = rrd_open(filename, &rrd, RRD_READONLY | RRD_READAHEAD);
    if (rrd_file == NULL) {
        rrd_free(&rrd);
        return (-1);
    }
    rra_base = rrd_file->header_len;
    rra_next = rra_base;

    for (i = 0; i < rrd.stat_head->rra_cnt; i++) {

        long      timer = 0;

        rra_start = rra_next;
        rra_next += (rrd.stat_head->ds_cnt
                     * rrd.rra_def[i].row_cnt * sizeof(rrd_value_t));



        rrd_seek(rrd_file, (rra_start + (rrd.rra_ptr[i].cur_row + 1)
                            * rrd.stat_head->ds_cnt
                            * sizeof(rrd_value_t)), SEEK_SET);

        ii = rrd.rra_ptr[i].cur_row;

	//for each archive
        for (ix = 0; ix < rrd.rra_def[i].row_cnt; ix++) {
            ii++;
            if (ii >= rrd.rra_def[i].row_cnt) {
                rrd_seek(rrd_file, rra_start, SEEK_SET);
                ii = 0; /* wrap if max row cnt is reached */
            }

	    //for each data source 
            for (iii = 0; iii < rrd.stat_head->ds_cnt; iii++) {
                rrd_read(rrd_file, &my_cdp, sizeof(rrd_value_t) * 1);
                if (isnan(my_cdp)) {
		//TODO put symbol R_NaReal
                } else {
		//put number
                }
            }
        }
    }


    rrd_free(&rrd);

    rrd_close(rrd_file);

}


