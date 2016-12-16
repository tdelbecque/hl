library (RPostgreSQL)

getConnection <- function (dbname) {
    m <- dbDriver("PostgreSQL")
    dbConnect(m, dbname=dbname)
}

closeConnection <- function (con) {
    postgresqlCloseConnection(con)
}

getData <- function () {
    read.table ('profiles.tsv', h=TRUE, sep='\t', comment.char ='', quote='',
                colClasses=list (PII='character', HL='character', SEGSUB='NULL', SEGPRED='NULL', SEGOBJ='NULL', SEGOTHER='NULL'))
}

getDataSQL <- function () {
    PROFILE_DB_NAME <- 'highlights'
    con <- getConnection (PROFILE_DB_NAME)
    query = "select PII, HLNO, DEPTH, DEPTHSUB, DEPTHOBJ, DEPTHPRED, NBT, NBTSUB, NBTOBJ, NBTPRED, DEP_AMOD, DEP_DEP, DEP_NMOD, DEP_OBJ, DEP_P, DEP_PMOD, DEP_PRD, DEP_ROOT, DEP_SBAR, DEP_SUB, DEP_VC, DEP_VMOD, POS_QENTER, POS_COMMA, POS_SEMIC, POS_DOR, POS_QLEAVE, POS_DOLLAR, POS_SHARP, POS_CC, POS_CD, POS_DT, POS_EX, POS_FW, POS_IN, POS_JJ, POS_JJR, POS_JJS, POS_LRB, POS_LS, POS_MD, POS_NN, POS_NNP, POS_NNPS, POS_NNS, POS_PDT, POS_POS, POS_PRP, POS_PRPDOLLAR, POS_RB, POS_RBR, POS_RBS, POS_RP, POS_RRB, POS_SYM, POS_TO, POS_UH, POS_VB, POS_VBD, POS_VBG, POS_VBN, POS_VBP, POS_VBZ, POS_WDT, POS_WP, POS_WPDOLLAR, POS_WRB, POS_QENTER_SUB, POS_COMMA_SUB, POS_SEMIC_SUB, POS_DOR_SUB, POS_QLEAVE_SUB, POS_DOLLAR_SUB, POS_SHARP_SUB, POS_CC_SUB, POS_CD_SUB, POS_DT_SUB, POS_EX_SUB, POS_FW_SUB, POS_IN_SUB, POS_JJ_SUB, POS_JJR_SUB, POS_JJS_SUB, POS_LRB_SUB, POS_LS_SUB, POS_MD_SUB, POS_NN_SUB, POS_NNP_SUB, POS_NNPS_SUB, POS_NNS_SUB, POS_PDT_SUB, POS_POS_SUB, POS_PRP_SUB, POS_PRPDOLLAR_SUB, POS_RB_SUB, POS_RBR_SUB, POS_RBS_SUB, POS_RP_SUB, POS_RRB_SUB, POS_SYM_SUB, POS_TO_SUB, POS_UH_SUB, POS_VB_SUB, POS_VBD_SUB, POS_VBG_SUB, POS_VBN_SUB, POS_VBP_SUB, POS_VBZ_SUB, POS_WDT_SUB, POS_WP_SUB, POS_WPDOLLAR_SUB, POS_WRB_SUB, POS_QENTER_OBJ, POS_COMMA_OBJ, POS_SEMIC_OBJ, POS_DOR_OBJ, POS_QLEAVE_OBJ, POS_DOLLAR_OBJ, POS_SHARP_OBJ, POS_CC_OBJ, POS_CD_OBJ, POS_DT_OBJ, POS_EX_OBJ, POS_FW_OBJ, POS_IN_OBJ, POS_JJ_OBJ, POS_JJR_OBJ, POS_JJS_OBJ, POS_LRB_OBJ, POS_LS_OBJ, POS_MD_OBJ, POS_NN_OBJ, POS_NNP_OBJ, POS_NNPS_OBJ, POS_NNS_OBJ, POS_PDT_OBJ, POS_POS_OBJ, POS_PRP_OBJ, POS_PRPDOLLAR_OBJ, POS_RB_OBJ, POS_RBR_OBJ, POS_RBS_OBJ, POS_RP_OBJ, POS_RRB_OBJ, POS_SYM_OBJ, POS_TO_OBJ, POS_UH_OBJ, POS_VB_OBJ, POS_VBD_OBJ, POS_VBG_OBJ, POS_VBN_OBJ, POS_VBP_OBJ, POS_VBZ_OBJ, POS_WDT_OBJ, POS_WP_OBJ, POS_WPDOLLAR_OBJ, POS_WRB_OBJ from profiles"
    rs <- dbSendQuery (con, query)
    ds <- fetch (rs, -1)
    dbClearResult (rs)
    closeConnection (con)
    ds
}

checkFreq <- function (data, pattern='POS_[^_]+$') {
    x <- matrix (nrow=0, ncol=2)
    for (i in grep (pattern, names (data)))
        x <- rbind (x, table (data [,i] > 0))
    x <- cbind (x, round (100.0 * (x /nrow (data)), 0))
    dimnames (x) [[1]] <- grep (pattern, names (data), value=TRUE)
    x
}

#x <- checkFreq (data)
#xsub <- checkFreq (data, 'POS_.+SUB$')
#xobj <- checkFreq (data, 'POS_.+OBJ$')

binarize <- function (data, cols, prefix='BIN_', condition = function (x) x > 0) {
    x <- list ()
    for (i in cols) 
        x [[paste (prefix, i, sep='')]] <- as.factor (ifelse (condition (data [, i]), 1, 0))
    as.data.frame (x)
}

binarize_batch <- function (data, freqTable, lower=10, upper=90, prefix='BIN_', condition = function (x) x > 0) {
    cols <- dimnames (freqTable [ freqTable [, 4] %in% lower:upper, ])[[1]]
    binarize (data, cols, prefix, condition)
}

binarize_onvalue <- function (data, cols, prefix='BIN_') {
    x <- list ()
    for (col in cols) 
        for (i in min (data [,col]):max (data [,col])) 
            x [[paste (prefix, col, '_', i, sep='')]] <- as.factor (ifelse (data [,col] == i, 1, 0))
    as.data.frame (x)
}

#dataBin <- cbind (binarize_onvalue (data, c ('DEPTHSUB', 'DEPTHOBJ')), binarize_batch (data, xsub), binarize_batch (data, xobj))

splitBalance <- function (data, cols=names (data)) {
    ret <- matrix (nrow=0, ncol=3)
    for (col in cols) {
        x <- table (data [,col])
        ret <- rbind (ret, c (as.numeric (x), as.numeric (abs (x [1] - x [2]) / nrow (data))))
    }
    dimnames (ret) <- list (cols, c ('LEFT', 'RIGHT', 'BALANCE'))
    ret
}

buildTree <- function (data, filter, cols, currentDepth, minCount, flags, maxDepth, branch='') {
    cat ('Entering foo : ', branch, ' , ', currentDepth, ' ==> ')
    splits <- splitBalance (data [filter,][cols])
    o <- order (splits [,3])
    candidate <- dimnames (splits) [[1]][o [1]]
    split <- splits [o [1],]
    cat (candidate, '\n')
    fleft <- filter & data [, candidate] == 0
    flags [fleft] <- paste (flags [fleft], ',', candidate, '(LEFT)', sep='')
    fright <- filter & data [, candidate] != 0
    flags [fright] <- paste (flags [fright], ',', candidate, '(RIGHT)', sep='')
    if (length (cols) > 1 && currentDepth < maxDepth && splits [1] > 0 && splits [2] > 0) {
        newcols <- character ()
        for (c in cols) 
            if (c != candidate) newcols <- c (newcols, c)
        currentDepth <- currentDepth + 1
        if (splits [1] >= minCount)
            flags <- foo (data, fleft, newcols, currentDepth, minCount, flags, maxDepth, 'LEFT')
        if (splits [2] >= minCount)
            flags <- foo (data, fright, newcols, currentDepth, minCount, flags, maxDepth, 'RIGHT')
    }
    flags
}

callBuildTree <- function (data) {
    filter <- rep (TRUE, nrow(data))
    flags <- rep ('', nrow(data))
    cols <- names (data)
    minCount <- 50000
    maxDepth <- 1000
    flags <- foo (data, filter, cols, 1, minCount, flags, maxDepth)
    gsub ('^,', flags, rep='', perl=TRUE)
}

foo <- function (data, N, file) {
    cat ('', file=file, append=FALSE)
    DEPTHSUB <- as.factor (data$DEPTHSUB+1)
    DEPTHOBJ <- as.factor (data$DEPTHOBJ+1)
    DEPTHPRED <- as.factor (data$DEPTHPRED+1)
    for (i in levels (DEPTHSUB))
        for (j in levels (DEPTHOBJ))
            for (k in levels (DEPTHPRED)) {
                hlset <- data [DEPTHSUB==i & DEPTHOBJ==j & DEPTHPRED==k, c('PII', 'HLNO', 'HL')]
                n <- length (hlset)
                cat (i, j, k, n, sep='\t', file=file, append=TRUE)
                cat ('\n', file=file, append=TRUE)
                if (n > 0) {
                    s <- sample (1:n, min (N, n))
                    write.table (hlset[s,],
                                 quote=FALSE, row.names=FALSE, col.names=FALSE,
                                 file=file, append=TRUE)
                }
                cat ('\n', file=file, append=TRUE)
            }
}
