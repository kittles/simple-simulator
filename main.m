#include <time.h>
#include <stdio.h>
#include <string.h>

int countChars( char* s, char c )
{
    return *s == '\0' ? 0 : countChars( s + 1, c ) + (*s == c);
}


int main(int argc, const char * argv[])
{
    
    
    
    // read txt into arrays ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
    
    // 602 transition labels
    char *transLabels[602];
    double trans[602][602];
    
    int size = 4000, pos;
    int c;
    int loopCounter = 0;
    char *buffer = (char *)malloc(size);
    FILE *f = fopen("transitions.txt", "rt");
    if(f)
    {
        // read all lines in file
        do
        {
            pos = 0;
            
            // read one line
            do
            {
                c = fgetc(f);
                
                if(c != EOF)
                {
                    buffer[pos++] = (char)c;
                }
                
                if(pos >= size - 1)
                { // increase buffer length - leave room for 0
                    size *=2;
                    buffer = (char*)realloc(buffer, size);
                }
                
            } while(c != EOF && c != '\n');
            
            // line is now in buffer
            buffer[pos] = 0;
            
            // this is the first line, need to make the label array
            if (loopCounter == 0)
            {
                // split line on spaces into array
                char *pch;
                pch = strtok(buffer, " ");
                int idx = 0;
                
                while (pch != NULL)
                {
                    transLabels[idx] = strdup(pch);
                    pch = strtok(NULL, " ");
                    idx++;
                }
            }
            // add a row of transition probabilities to trans array
            else
            {
                // split line on spaces into array
                char *pch;
                pch = strtok(buffer, " ");
                int idx = 0;
                
                while (pch != NULL)
                {
                    double result = atof(pch);
                    trans[loopCounter - 1][idx] = result;
                    pch = strtok(NULL, " ");
                    idx++;
                }
            }
            
            loopCounter++;
        
        } while(c != EOF);
        fclose(f);
        
    }
    free(buffer);
    
    
    
    // run a simulation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
    
    // seed random number generator
    srand48(time(0));
    
    // find index of 'START', 'ENDTT', and 'ENDFF' in transLabels
    int startIndex = 0;
    int endTTIndex = 0;
    int endFFIndex = 0;
    for (int i = 0 ; i < 602; i++)
    {
        if (strncmp(transLabels[i], "START", 10) == 0)
        {
            startIndex = i;
        }
        if (strncmp(transLabels[i], "END-T", 10) == 0)
        {
            endTTIndex = i;
        }
        if (strncmp(transLabels[i], "END-F", 10) == 0)
        {
            endFFIndex = i;
        }
    }
    

    // start timing the cpu
    clock_t start_t, end_t;
    double total_t;
    start_t = clock();
    
    int runsAvg = 0;
    int runsArraySize = 20;
    int runsArray[runsArraySize];
    for (int i=0; i<runsArraySize; i++) {
        runsArray[i] = 0;
    }
    
    // sample some half innings
    for (int c = 0; c < 1e6; c++) {

        // initialize the variables to track
        int runs = 0;
        int currentState = startIndex;
        
        // run a half inning
        while (true) {
            
            // generate random sample
            double sample = drand48();
            
            // initialize index that will walk along current state's probs array
            int sIndex = -1;
            
            
            // walk along the array, subtracting each items's probability weight
            while (sample > 0.0)
            {
                sIndex++;
                sample -= trans[currentState][sIndex];
            }
            
            // sIndex now represents the resulting transition
            // printf("%s goes to %s \n", transLabels[currentState], transLabels[sIndex]);
            
            if (sIndex == endTTIndex) {
                break;
            }
            else if (sIndex == endFFIndex) {
                break;
            }
            else if (sIndex == startIndex) {
                break;
            }
            else {
                runs += countChars(transLabels[sIndex], '4');
                currentState = sIndex;
            }
            
        }
        
        if (runs < runsArraySize) {
            runsArray[runs]++;
        }
        runsAvg += runs;
    }
    
    end_t = clock();
    total_t = (end_t - start_t) / (CLOCKS_PER_SEC * 1.0);
    printf("half inning run distribution: \n");
    for (int i=0; i<runsArraySize; i++) {
        printf("    %d runs: %d \n", i, runsArray[i]);
    }
    printf("Average runs in a half inning: %f \n", (runsAvg / 1e6));
    printf("Total time taken by CPU: %f \n", total_t);
    return(0);
}

