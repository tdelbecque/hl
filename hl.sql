/*
drop table if exists triplets;

create table triplets (
       PII   CHARACTER(17),
       HLNO  INTEGER,
       SUB   TEXT,
       VERB  TEXT,
       OBJECT	TEXT,
       DEPTH	INTEGER,
       LEN	INTEGER,
       SLEN	INTEGER,
       VLEN	INTEGER,
       OLEN	INTEGER);


\copy triplets from 'triplets-heights.tsv' with csv delimiter E'\t' HEADER;

alter table triplets add primary key (pii, hlno);

drop table if exists parsing ;

create table parsing (
       PII   CHARACTER(17),
       HLNO  INTEGER,
       TOKNO INTEGER,
       TOKEN TEXT,
       GRAM  TEXT,
       PARENT INTEGER,
       CAT    TEXT,
       SEGMENT	TEXT);

\copy parsing from 'triplets-forsql.tsv' with csv delimiter E'\t' HEADER;

alter table parsing add primary key (pii, hlno, tokno);

drop index if  exists triplets_object_idx;
create index triplets_object_idx on triplets(object);

drop index if exists parsing_token_idx;
create index parsing_token_idx on parsing(token);

vacuum full analyze;

*/
/*
\copy (select count(*) n, token from parsing where cat='ROOT' and gram like 'V%' group by token order by n desc) to 'verbs.tsv';

drop table if exists foo;
create table foo as (
      select count(*) n, verb, object
      from (select * from triplets where olen < 4 and object <> '.') T
      join (select * from parsing where segment = 'OBJ' and gram not like 'V%') P
      on T.pii = P.pii and T.hlno = P.hlno
      group by verb, object
      order by n desc);
\copy foo to 'predicats-simple.tsv';

drop table if exists p1;
create table P1 as select pii, hlno, tokno from parsing where token = 'can' and segment='PRED';
drop table if exists p2;
create table P2 as select pii, hlno, token, tokno, parent, cat from parsing where gram like 'V%';
drop table if exists cancomplement;
create table cancomplement as select p2.pii, p2.hlno, token, p2.tokno - p1.tokno as delta, cat from  p1 join  p2 on (p1.pii = p2.pii and p1.hlno = p2.hlno and p2.parent = p1.tokno and p2.tokno - p1.tokno between 1 and 3);

drop table if exists p1;
create table P1 as select pii, hlno, token, cat, tokno, gram from parsing where segment='PRED';
drop table if exists p2;
create table P2 as select pii, hlno, token, tokno, parent, cat from parsing where gram like 'V%';
drop table if exists foo;
create table foo as select p2.pii, p2.hlno, p1.token t1, p2.token t2, p1.cat c1, p2.cat c2, gram from  p1 join  p2 on (p1.pii = p2.pii and p1.hlno = p2.hlno and p2.parent = p1.tokno and p2.tokno - p1.tokno between 1 and 3);


ROOT = {"can may could should will might would must need shall ought can't" and gram = MD}; parent = root.tokno and delta => PRED.

Filtrer le pred selon gram dans V% ou MD.
*/

drop table if exists profiles;
create table profiles (
	PII	CHARACTER(17),
	HLNO	INTEGER,
	HL	TEXT,
	SEGSUB	TEXT,
	SEGPRED	TEXT,
	SEGOBJ	TEXT,
	SEGOTHER TEXT,
	DEPTH	INTEGER,
	DEPTHSUB	INTEGER,
	DEPTHOBJ	INTEGER,
	DEPTHPRED	INTEGER,
	NBT	INTEGER,
	NBTSUB	INTEGER,
	NBTOBJ	INTEGER,
	NBTPRED	INTEGER,
	DEP_AMOD	INTEGER,
	DEP_DEP	INTEGER,
	DEP_NMOD	INTEGER,
	DEP_OBJ	INTEGER,
	DEP_P	INTEGER,
	DEP_PMOD	INTEGER,
	DEP_PRD	INTEGER,
	DEP_ROOT	INTEGER,
	DEP_SBAR	INTEGER,
	DEP_SUB	INTEGER,
	DEP_VC	INTEGER,
	DEP_VMOD	INTEGER,
	POS_QENTER	INTEGER,
	POS_COMMA	INTEGER,
	POS_SEMIC	INTEGER,
	POS_DOR	INTEGER,
	POS_QLEAVE	INTEGER,
	POS_DOLLAR	INTEGER,
	POS_SHARP	INTEGER,
	POS_CC	INTEGER,
	POS_CD	INTEGER,
	POS_DT	INTEGER,
	POS_EX	INTEGER,
	POS_FW	INTEGER,
	POS_IN	INTEGER,
	POS_JJ	INTEGER,
	POS_JJR	INTEGER,
	POS_JJS	INTEGER,
	POS_LRB	INTEGER,
	POS_LS	INTEGER,
	POS_MD	INTEGER,
	POS_NN	INTEGER,
	POS_NNP	INTEGER,
	POS_NNPS	INTEGER,
	POS_NNS	INTEGER,
	POS_PDT	INTEGER,
	POS_POS	INTEGER,
	POS_PRP	INTEGER,
	POS_PRPDOLLAR	INTEGER,
	POS_RB	INTEGER,
	POS_RBR	INTEGER,
	POS_RBS	INTEGER,
	POS_RP	INTEGER,
	POS_RRB	INTEGER,
	POS_SYM	INTEGER,
	POS_TO	INTEGER,
	POS_UH	INTEGER,
	POS_VB	INTEGER,
	POS_VBD	INTEGER,
	POS_VBG	INTEGER,
	POS_VBN	INTEGER,
	POS_VBP	INTEGER,
	POS_VBZ	INTEGER,
	POS_WDT	INTEGER,
	POS_WP	INTEGER,
	POS_WPDOLLAR	INTEGER,
	POS_WRB	INTEGER,
	POS_QENTER_SUB	INTEGER,
	POS_COMMA_SUB	INTEGER,
	POS_SEMIC_SUB	INTEGER,
	POS_DOR_SUB	INTEGER,
	POS_QLEAVE_SUB	INTEGER,
	POS_DOLLAR_SUB	INTEGER,
	POS_SHARP_SUB	INTEGER,
	POS_CC_SUB	INTEGER,
	POS_CD_SUB	INTEGER,
	POS_DT_SUB	INTEGER,
	POS_EX_SUB	INTEGER,
	POS_FW_SUB	INTEGER,
	POS_IN_SUB	INTEGER,
	POS_JJ_SUB	INTEGER,
	POS_JJR_SUB	INTEGER,
	POS_JJS_SUB	INTEGER,
	POS_LRB_SUB	INTEGER,
	POS_LS_SUB	INTEGER,
	POS_MD_SUB	INTEGER,
	POS_NN_SUB	INTEGER,
	POS_NNP_SUB	INTEGER,
	POS_NNPS_SUB	INTEGER,
	POS_NNS_SUB	INTEGER,
	POS_PDT_SUB	INTEGER,
	POS_POS_SUB	INTEGER,
	POS_PRP_SUB	INTEGER,
	POS_PRPDOLLAR_SUB	INTEGER,
	POS_RB_SUB	INTEGER,
	POS_RBR_SUB	INTEGER,
	POS_RBS_SUB	INTEGER,
	POS_RP_SUB	INTEGER,
	POS_RRB_SUB	INTEGER,
	POS_SYM_SUB	INTEGER,
	POS_TO_SUB	INTEGER,
	POS_UH_SUB	INTEGER,
	POS_VB_SUB	INTEGER,
	POS_VBD_SUB	INTEGER,
	POS_VBG_SUB	INTEGER,
	POS_VBN_SUB	INTEGER,
	POS_VBP_SUB	INTEGER,
	POS_VBZ_SUB	INTEGER,
	POS_WDT_SUB	INTEGER,
	POS_WP_SUB	INTEGER,
	POS_WPDOLLAR_SUB	INTEGER,
	POS_WRB_SUB	INTEGER,
	POS_QENTER_OBJ	INTEGER,
	POS_COMMA_OBJ	INTEGER,
	POS_SEMIC_OBJ	INTEGER,
	POS_DOR_OBJ	INTEGER,
	POS_QLEAVE_OBJ	INTEGER,
	POS_DOLLAR_OBJ	INTEGER,
	POS_SHARP_OBJ	INTEGER,
	POS_CC_OBJ	INTEGER,
	POS_CD_OBJ	INTEGER,
	POS_DT_OBJ	INTEGER,
	POS_EX_OBJ	INTEGER,
	POS_FW_OBJ	INTEGER,
	POS_IN_OBJ	INTEGER,
	POS_JJ_OBJ	INTEGER,
	POS_JJR_OBJ	INTEGER,
	POS_JJS_OBJ	INTEGER,
	POS_LRB_OBJ	INTEGER,
	POS_LS_OBJ	INTEGER,
	POS_MD_OBJ	INTEGER,
	POS_NN_OBJ	INTEGER,
	POS_NNP_OBJ	INTEGER,
	POS_NNPS_OBJ	INTEGER,
	POS_NNS_OBJ	INTEGER,
	POS_PDT_OBJ	INTEGER,
	POS_POS_OBJ	INTEGER,
	POS_PRP_OBJ	INTEGER,
	POS_PRPDOLLAR_OBJ	INTEGER,
	POS_RB_OBJ	INTEGER,
	POS_RBR_OBJ	INTEGER,
	POS_RBS_OBJ	INTEGER,
	POS_RP_OBJ	INTEGER,
	POS_RRB_OBJ	INTEGER,
	POS_SYM_OBJ	INTEGER,
	POS_TO_OBJ	INTEGER,
	POS_UH_OBJ	INTEGER,
	POS_VB_OBJ	INTEGER,
	POS_VBD_OBJ	INTEGER,
	POS_VBG_OBJ	INTEGER,
	POS_VBN_OBJ	INTEGER,
	POS_VBP_OBJ	INTEGER,
	POS_VBZ_OBJ	INTEGER,
	POS_WDT_OBJ	INTEGER,
	POS_WP_OBJ	INTEGER,
	POS_WPDOLLAR_OBJ	INTEGER,
	POS_WRB_OBJ	INTEGER);
alter table profiles add primary key (pii, hlno);
\copy profiles from 'profiles.tsv' with csv delimiter E'\t' HEADER;
drop index if exists profiles_pii_idx;
create index profiles_pii_idx on profiles (pii);

