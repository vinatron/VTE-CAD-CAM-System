/********************************************
* VINATRON EXEC WRITTEN BY VINCENT F. MANZO *
*            JANUARY 9 2023                 *
*  A PROGRAM FOR GRAPHING NC CODE WITH GDDM *
*********************************************/

ADDRESS COMMAND 'GDDMREXX INIT'              /* INITIALIZE GDDM */
ADDRESS GDDM                                 /* WE ARE TALKING TO GDDM */       

/* INIT VARS */
TESTGDD = 1                                  /* SKIP TO GDDM INPUT */
DEBUG = 0                                    /* ENABLE/DISABLE DEBUGGING */
GMOTION = 0                                  /* CURRENT G-COMMAND */
DATUM = 0                                    /* PART DATUM */
TXTF = ''                                    /* FIELD TEXT */
TXTL = 0                                     /* TEXT LENGTH */
RC = 0                                       /* ERROR VAREABLE */

TRACE E                                      /* ERROR TRACING */

PARSE ARG FN FT FM                           /* PARSE ARGS */

/* BANNER START */
SAY "STARTING VINATRON'S NC PLOT UTILITY FOR VM"
SAY 'PROPERTY OF:'                           /* BANNER */
SAY 'VINATRON TECHNOLOGY AND ELECTRICAL'     /* BANNER END */

SIGNAL ON ERROR                              /* TEST RC OF COMMANDS */

IF DEBUG = 1 THEN DO                         /* START DEBUG IF DEBUG = 1 */
 TRACE R                                     /* START REXX TRACING */
 'GXSET TRACE ON TIME'                       /* START GDDM-REXX TRACING */
END                                          /* END DEBUG START */

IF TESTGDD = 1 THEN DO                      /* START GDDM TEST IF TESTGDD = 1 */
 SIGNAL DATUM                               /* JUMP TO DATUM */
END                                         /* END DEBUG START */

INPUTTEST:
/* TEST IF ARGUMENTS ARE NULL AND START INTERACTIVE INPUT */
IF LENGTH(FN) = 0 THEN DO
 SAY 'INPUT NC FILENAME NOT SPECIFIED PLEASE INPUT A NC FILENAME'
 PULL FN
END
IF LENGTH(FT) = 0 THEN DO 
 SAY 'INPUT NC FILETYPE NOT SPECIFIED PLEASE INPUT A NC FILETYPE'
 PULL FT
END
IF LENGTH(FM) = 0 THEN DO
 SAY 'OUTPUT NC FILEMODE NOT SPECIFIED PLEASE INPUT A NC FILEMODE'
 PULL FM
END

NC = FN FT FM                                /* INPUT FILE */

/* TEST IF INPUT ARGUMENTS ARE CORRECT */
INTST = STREAM(NC,'C','QUERY EXISTS')
IF LENGTH(INTST) = 0 THEN DO
 SAY 'INPUT FILE DOESNT EXIST! SPECIFY NEW NC FILE.'
 SAY 'INPUT NEW NC FILENAME:'
 PULL FN
 SAY 'INPUT NEW NC FILETYPE:'
 PULL FT
 SAY 'INPUT NEW NC FILEMODE:'
 PULL FM
 SIGNAL INPUTTEST
END

DATUM:                                       /* DRAW DATUM ROUTINE */
/* DRAW HAAS VQC STYLE DATUM SELECT */
/* DEFINE ERROR FIELD */
'ASFLD 2 1 1 1 60 2'
/* CHECK RC OF PREVIOUS OPERATION */
IF RC = 10 THEN DO
 TXTF = 'INPUT INVALID PLEASE SPECIFY AN INTEGER BETWEEN 1 AND 9' 
 TXTL = LENGTH(TXTF)
 'ASCPUT 2 .TXTL .TXTF'
 'ASFCOL 2 2'
 'ASFHTL 2 2'
END
/* DRAW 80X80 SQUARE */
'GSMOVE 20 20'                                             
'GSLINE 80 20'                                             
'GSLINE 80 80'                                             
'GSLINE 20 80'                                             
'GSLINE 20 20'                                             
/* DRAW LOCATION CHARACTURES */
'GSCHAR 21 21 1 1'                                         
'GSCHAR 21 78 1 2'                                         
'GSCHAR 78 78 1 3'                                         
'GSCHAR 78 21 1 4'                                         
'GSCHAR 50 50 1 5'                                         
'GSCHAR 78 50 1 6'                                         
'GSCHAR 50 21 1 7'                                         
'GSCHAR 21 50 1 8'                                         
'GSCHAR 50 78 1 9'                                         
/* DRAW BANNER */
'GSCHAR 45 81 17 "SELECT WORK DATUM"'                      
/* DRAW FIELD MARKER */
'GSCHAR 01 01 4 "===>"'                                    
/* CREATE INPUT FIELD AND MOVE CUSOR TO FIELD */
'ASDFLD 1 61 8 1 1 1'                                      
'ASFCUR 1 -1 1'                        
'ASREAD . . .'                       /* SEND TO TERMINAL AFTER PRESSING ENTER */          
'ASCGET 1 1 .DATUM'             /* GET INT FROM FIELD 1 AND PUT INTO VARIABLE */
IF (DATUM > 9) | (DATUM < 1) THEN DO         /* TEST FOR INVALID INPUT */
 RC = 10                                     /* SET INVALID INPUT RC */
 SIGNAL DATUM                                /* JUMP TO DRAW DATUM */
END

SAY 'YOUR DATUM SELECTION WAS:' DATUM        /* NOTIFY USER */

ADDRESS COMMAND 'GDDMREXX TERM'              /* TERMINATE GDDM */

EXIT                                         /* END OF PROGRAM */

/********************************************************
*             LINE TYPE SELECTOR SUBROUTINE             *
********************************************************/

LINETYPE:
 /* TEST IF MOTION IS RAPID TRAVERSE G0 */
 IF GMOTION = 0 THEN DO
  'GSLT 1'                                   /* SET LINE TYPE TO DOTTED */         
 END
 
 /* TEST IF MOTION IS G1 LINEAR FEED MOVE OR G2/G3 ARC */
 IF (GMOTION = 1) | (GMOTION = 2) | (GMOTION = 3) THEN DO
  'GSLT 0'                                   /* SET LINE TYPE SOLID DEFAULT */
 END
RETURN

/*******************************************************/
/* ERROR HANDLER: COMMON EXIT FOR NONZERO RETURN CODES */
/*******************************************************/
ERROR:
SAY "UNEXPECTED RC" RC "FROM COMMAND:"
SAY "     " SOURCELINE(SIGL)
SAY "AT LINE" SIGL"."
