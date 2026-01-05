#include <sys/time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <stdbool.h>

// 5 scopes * 4 channels
#define MAX_COLS 20
#define MAXCHAR_COL 50
// 20 * 50
#define MAXCHAR_LINE (MAX_COLS * MAXCHAR_COL)

static const double POW10_2 = 100.0;
static const double INV_TIMESTEP = 1e9; // seconds -> nanoseconds

static inline double roundn(double f, int n) {
    double scale = (n == 2) ? POW10_2 : pow(10.0, n);
    return round(f * scale) / scale;
}

static inline int split_row(char *row, char **cols, int max_cols) {
    int count = 0;
    char *start = row;
    while (count < max_cols && start) {
        cols[count++] = start;
        char *comma = strchr(start, ',');
        if (!comma) {
            break;
        }
        *comma = '\0';
        start = comma + 1;
    }
    return count;
}

int main(int argc, char **argv) {

    struct timeval start, end;
 
    gettimeofday(&start, NULL);

    if (argc != 3)
    {
        printf("Error expecting csv2vcd <csv> <vcd>\n");
        exit(1);
    }

    FILE *csv, *vcd;
    char row[MAXCHAR_LINE];
    char *cols[MAX_COLS];

    int row_counter = 0;
    int col;
    bool updated;
    double prev[MAX_COLS];
    double cur[MAX_COLS];

    csv = fopen(argv[1],"r");
    vcd = fopen(argv[2], "w");
    if ((csv == NULL) || (vcd == NULL))
    {
        printf("Error opening file!\n");
        exit(1);
    }

    setvbuf(csv, NULL, _IOFBF, 1 << 20);
    setvbuf(vcd, NULL, _IOFBF, 1 << 20);

    time_t t = time(NULL);
    struct tm tm = *localtime(&t);
 
    // Print Header """
    fprintf(vcd,"$date %d-%02d-%02d %02d:%02d:%02d $end\n", tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec);
    fprintf(vcd,"$timescale 1ns $end\n");
    fprintf(vcd,"$scope module dut $end\n");
 
    while (fgets(row, MAXCHAR_LINE, csv) != NULL)
    {

        char *newline = strchr(row, '\n');
        if (newline) {
            *newline = '\0';
        }

        col = split_row(row, cols, MAX_COLS);

        if (row_counter == 0) 
        {
            // header
            for (int i=1; i < col; i++) {
                fprintf(vcd,"$var real 64 %c %s $end\n", 33+i-1, cols[i]);
            }
            fprintf(vcd,"$upscope $end\n");
            fprintf(vcd,"$enddefinitions $end\n");
        } 
        else if (row_counter == 1)
        {
            // Initial Value Dump
            fprintf(vcd,"#0\n");
            fprintf(vcd,"$dumpvars\n");
            for (int i=1; i < col; i++) {
                prev[i] = roundn(strtod(cols[i], NULL), 2);
                fprintf(vcd,"r%g %c\n", prev[i], 33+i-1);
            }
            fprintf(vcd,"$end\n");
        }
        else
        {
            updated = false;
            for (int i=1; i < col; i++) {
                cur[i] = roundn(strtod(cols[i], NULL), 2);
                if (prev[i] != cur[i]) {
                    updated = true;
                }
            }
            if (updated)
            {
               fprintf(vcd, "#%.0f\n", round(strtod(cols[0], NULL) * INV_TIMESTEP));
                for (int i=1; i < col; i++) {
                    if ( prev[i] != cur[i] ) { 
                      fprintf(vcd,"r%g %c\n",cur[i], 33+i-1);
                      prev[i] = cur[i];
                    }
                }
            }
                                    
        }

        row_counter++;

    }

    fclose(csv);
    fclose(vcd);

    gettimeofday(&end, NULL);
    
    long seconds  = (end.tv_sec  - start.tv_sec);
    long useconds = (end.tv_usec - start.tv_usec);
    double diff = seconds + useconds / 1e6;

    printf("Done, processed %i rows. The elapsed time is %.3f seconds.\n", row_counter, diff);

    return 0;
}
