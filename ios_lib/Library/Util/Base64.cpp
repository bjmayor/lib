#include <string.h>
#include <stdlib.h>
#include "Base64.h"
unsigned int g_base64_encode_step(const unsigned char *in, unsigned int len,
                                  int break_lines, char *out, int *state, int *save);
unsigned int g_base64_encode_close(int break_lines, char *out, int *state,
                                   int *save);
unsigned int g_base64_decode_step(const char *in, unsigned int len,
                                  unsigned char *out, int *state, unsigned int *save);

unsigned int g_base64_encode_step(const unsigned char *in, unsigned int len,
        int break_lines, char *out, int *state, int *save)
{
    char base64_alphabet[] =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    char *outptr;
    const unsigned char *inptr;

    if (len <= 0)
        return 0;

    inptr = in;
    outptr = out;

    if (len + ((char *) save)[0] > 2)
    {
        const unsigned char *inend = in + len - 2;
        int c1, c2, c3;
        int already;

        already = *state;

        switch(((char *) save)[0])
        {
            case 1:
                c1 = ((unsigned char *) save)[1];
                goto skip1;
            case 2:
                c1 = ((unsigned char *) save)[1];
                c2 = ((unsigned char *) save)[2];
                goto skip2;
        }

        /*
          *yes, we jump into the loop, no i'm not going to change it, 
          *it's beautiful! 
         */
        while (inptr < inend)
        {
            c1 = *inptr++;
            skip1: c2 = *inptr++;
            skip2: c3 = *inptr++;
            *outptr++ = base64_alphabet[c1 >> 2];
            *outptr++ = base64_alphabet[c2 >> 4 | ((c1 & 0x3) << 4)];
            *outptr++ = base64_alphabet[((c2 & 0x0f) << 2) | (c3 >> 6)];
            *outptr++ = base64_alphabet[c3 & 0x3f];
            /*this is a bit ugly ... */
            if (break_lines && (++already) >= 19)
            {
                *outptr++ = '\n';
                already = 0;
            }
        }

        ((char *) save)[0] = 0;
        len = (unsigned int) 2 - (inptr - inend);
        *state = already;
    }

    if (len > 0)
    {
        char *saveout;

        /*points to the slot for the next char to save */
        saveout = &(((char *) save)[1]) + ((char *) save)[0];

        /*len can only be 0 1 or 2 */
        switch(len)
        {
            case 2:
                *saveout++ = *inptr++;
            case 1:
                *saveout++ = *inptr++;
        }
        ((char *) save)[0] += len;
    }

    return (unsigned int) (outptr - out);
}

/**
  *g_base64_encode_close:
  *@break_lines: whether to break long lines
  *@out: pointer to destination buffer
  *@state: Saved state from g_base64_encode_step()
  *@save: Saved state from g_base64_encode_step()
 *
  *Flush the status from a sequence of calls to g_base64_encode_step().
 *
  *Return value: The number of bytes of output that was written
 *
  *Since: 2.12
 */
unsigned int g_base64_encode_close(int break_lines, char *out, int *state,
        int *save)
{
    char base64_alphabet[] =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    int c1, c2;
    char *outptr = out;

    c1 = ((unsigned char *) save)[1];
    c2 = ((unsigned char *) save)[2];

    switch(((char *) save)[0])
    {
        case 2:
            outptr[2] = base64_alphabet[((c2 & 0x0f) << 2)];
            //      g_assert (outptr [2] != 0);
            goto skip;
        case 1:
            outptr[2] = '=';
            skip: outptr[0] = base64_alphabet[c1 >> 2];
            outptr[1] = base64_alphabet[c2 >> 4 | ((c1 & 0x3) << 4)];
            outptr[3] = '=';
            outptr += 4;
            break;
    }
    if (break_lines > 1)
        *outptr++ = '\n';

    *save = 0;
    *state = 0;

    return (unsigned int) (outptr - out);
}

/**
  *g_base64_encode:
  *@data: the binary data to encode.
  *@len: the length of @data.
 *
  *Encode a sequence of binary data into its Base-64 stringified
  *representation.
 *
  *Return value: a newly allocated, zero-terminated Base-64 encoded
  *    string representing @data.
 *
  *Since: 2.12
 */
char *
Base64Encode(const char *data, int len)
{
    char *out;
    int state = 0, outlen;
    int save = 0;

    /*We can use a smaller limit here, since we know the saved state is 0 */
    out = (char*) malloc(len  *2 + 4);
    outlen = g_base64_encode_step((const unsigned char*) data, len, false, out,
            &state, &save);
    outlen += g_base64_encode_close(false, out + outlen, &state, &save);
    out[outlen] = '\0';
    return (char *) out;
}

/**
  *g_base64_decode_step: 
  *@in: binary input data
  *@len: max length of @in data to decode
  *@out: output buffer
  *@state: Saved state between steps, initialize to 0
  *@save: Saved state between steps, initialize to 0
 *
  *Incrementally decode a sequence of binary data from its Base-64 stringified
  *representation. By calling this function multiple times you can convert 
  *data in chunks to avoid having to have the full encoded data in memory.
 *
  *The output buffer must be large enough to fit all the data that will
  *be written to it. Since base64 encodes 3 bytes in 4 chars you need
  *at least: @len  *3 / 4 bytes.
  *
  *Return value: The number of bytes of output that was written
 *
  *Since: 2.12
 **/
unsigned int g_base64_decode_step(const char *in, unsigned int len,
        unsigned char *out, int *state, unsigned int *save)
{
    const unsigned char *inptr;
    unsigned char *outptr;
    const unsigned char *inend;
    unsigned char c, rank;
    unsigned char last[2];
    unsigned int v;
    int i;

    const unsigned char mime_base64_rank[256] = {
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 62, 255, 255, 255, 63, 52, 53, 54, 55, 56, 57, 58, 59,
            60, 61, 255, 255, 255, 0, 255, 255, 255, 0, 1, 2, 3, 4, 5, 6, 7, 8,
            9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
            255, 255, 255, 255, 255, 255, 26, 27, 28, 29, 30, 31, 32, 33, 34,
            35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255,
    };

    inend = (const unsigned char *) in + len;
    outptr = out;

    /*convert 4 base64 bytes to 3 normal bytes */
    v = *save;
    i = *state;
    inptr = (const unsigned char *) in;
    last[0] = last[1] = 0;
    while (inptr < inend)
    {
        c = *inptr++;
        rank = mime_base64_rank[c];
        if (rank != 0xff)
        {
            last[1] = last[0];
            last[0] = c;
            v = (v << 6) | rank;
            i++;
            if (i == 4)
            {
                *outptr++ = v >> 16;
                if (last[1] != '=')
                    *outptr++ = v >> 8;
                if (last[0] != '=')
                    *outptr++ = v;
                i = 0;
            }
        }
    }

    *save = v;
    *state = i;

    return (unsigned int) (outptr - out);
}

/**
  *g_base64_decode:
  *@text: zero-terminated string with base64 text to decode.
  *@out_len: The length of the decoded data is written here.
 *
  *Decode a sequence of Base-64 encoded text into binary data
 *
  *Return value: a newly allocated buffer containing the binary data
  *    that @text represents
 *
  *Since: 2.12
 */
char *
Base64Decode(const char *text, int in_len, int &out_len)
{
    unsigned char *ret;
    int state = 0;
    unsigned int save = 0;

    ret = (unsigned char *) malloc(in_len);

    out_len = g_base64_decode_step(text, in_len, ret, &state, &save);

    return (char*) ret;
}

