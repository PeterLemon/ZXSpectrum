/*
Offline conversion of 8-bit sample files (RAW format, no header) to
1-bit sigma-delta encoded stream files.

(C)2012 Miguel Angel Rodriguez Jodar (mcleod_ideafix)
Dept. Architecture and Computer Technology. University of Seville, Spain
Licensed under the terms of GPL.

Change input and output files to suit your needs.
TO-DO: process input file in chunks, rather than completely load it in memory
*/

#define INPUTFILE "sample.raw"
#define OUTPUTFILE "sample.bin"

#include <stdio.h>
#include <stdlib.h>

void main (void)
{
    FILE *f;
    int leido;
    int i,sample,integrador,salida,filesize;
    unsigned char *buffer;    /* remove "unsigned" if using signed samples */
    unsigned char *buffout;

    f=fopen (INPUTFILE, "rb");
    fseek (f, 0, SEEK_END);
    filesize = ftell (f);
    fseek (f, 0, SEEK_SET);
    buffer=malloc(filesize);
    buffout=malloc(filesize/4);
    filesize = fread (buffer, 1, filesize, f);
    fclose(f);

    integrador = 0;
    salida = 0;
    memset (buffout, 0, filesize/4);

    for (i=0;i<filesize;i++)
    {
        sample = buffer[i]-128;  /* remove -128 if using signed samples */
        integrador += (sample-salida);
        if (integrador>0)
        {
            salida=127;
            buffout[i/4] = buffout[i/4] | (1<<(7-(i*2)%8));
        }
        else
        {
            salida=-128;
        }

        /* repeat once (2x oversampling) */
        integrador += (sample-salida);
        if (integrador>0)
        {
            salida=127;
            buffout[i/4] = buffout[i/4] | (1<<(7-(i*2+1)%8));
        }
        else
        {
            salida=-128;
        }
    }

    f=fopen (OUTPUTFILE, "wb");
    fwrite (buffout, 1, filesize/4, f);
    fclose(f);

    free(buffer);
    free(buffout);
}