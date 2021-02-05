

--DDL 다시 시작

--------------------------------------------------------
-- create
--------------------------------------------------------
-- 객체 생성
--subquery를 이용한 create는 not null 제약조건을 제외한 모든 제약조건, 기본값등을 제거한다. 

-- 컬럼명 자료형 [기본값] [제약조건]

-- 필수인 항목에는 not null
-- 기본값 설정 default

create table emp_bck 
as 
select * from employee;




--제약조건 검색
select constraint_name,
            uc.table_name,
            ucc.column_name,
            uc.constraint_type,
            uc.search_condition
from user_constraints uc
    join user_cons_columns ucc
        using(constraint_name)
where UC.table_name = 'EMP_BCK';

--기본값 확인
select *
from user_tab_cols
where table_name = 'EMP_BCK';

--------------------------------------------------------
-- ALTER
--------------------------------------------------------
-- 데이터베이스 객체에 대해서 수정명령어
--table 관련 alter문은 컬럼, 제약조건에 대해 수정이 가능

-- sub 명령어
-- table의 컬럼/제약조건에 대해서 다음 명령 실행
-- 1. add 컬럼/제약조건
-- 2. modify 컬럼(제약조건 수정 안됨)
-- 3. rename 컬럼/제약조건
-- 4. drop 컬럼/제약조건

create table tb_alter(
    no number
);

--add 컬럼
--맨 마지막 컬럼으로 추가
alter table tb_alter add name varchar2(100) not null;

describe tb_alter;-- = desc

--add 제약조건
--not null은 제약조건은 추가(add)가 아닌 수정(modify sub) 명령어를 사용해야 한다.
alter table tb_alter 
add constraint pk_tb_alter_no primary key(no);

select UC.table_name, 
       UCC.column_name, 
       constraint_name,
       UC.constraint_type,
       UC.search_condition
from user_constraints UC 
   join user_cons_columns UCC
     using(constraint_name)
where UC.table_name = 'TB_ALTER';

select * from tab;

--modify 컬럼
--자료형, 컬럼의 default값, null여부 변경 가능
--데이터가 있는 경우 자료형 변경 제한적으로 가능, 실제 저장된 데이터보다 큰 사이즈로만 가능하다.
--문자열에서 호환가능타입으로 변경가능(char --- varchar2)
desc tb_alter;

alter table tb_alter 
modify name varchar2(500) default '홍길동' null;

--행이 있다면 변경하는데 제한이 있다.
--존재하는 값보다는 작은크기로 변경불가.
--null값이 있는 컬럼을 not null로 변경불가.

--modify제약조건은 불가능
--제약조건은 이름 변경외에 변경불가
--해당 제약조건 삭제 후 재생성 할 것

--not null 제약조건 추가
alter table tb_alter
modify product_alter not null;

--rename 컬럼
alter table tb_alter
rename column no to num;

desc tb_alter;


--rename 제약조건
--제약조건은 이름 외에는 변경할 수 있는 게 없다.
select UC.table_name, 
       UCC.column_name, 
       UC.constraint_name,
       UC.constraint_type,
       UC.search_condition
from user_constraints UC join user_cons_columns UCC
     on UC.constraint_name = UCC.constraint_name
where UC.table_name = 'TB_ALTER';

alter table tb_alter
rename constraint PK_TB_ALTER_NO to pk_tb_alter_num;

--drop 컬럼
alter table tb_alter
drop column name;

desc tb_alter;

--drop 제약조건
alter table tb_alter
drop constraint pk_tb_alter_num;

--not null 제약조건 drop으로 삭제
alter table tb_alter
drop constraint pk_tb_alter_num;

--rename 테이블
alter table tb_alter
rename to tb_alter_new;

rename tb_alter_new to tb_alter_all_new;


select * from tb_alter_all_new;
--소유한 테이블 조회
select *
from tab;

------------------------------------------------------------------
--DROP
------------------------------------------------------------------
--데이터베이스 객체(table, user, view 등) 삭제
drop table tb_alter_all_new;



--======================================================
-- DCL
--======================================================
-- Data Control Language 데이터제어어
-- 보안, 무결성관련, 권한부여/회수, 복구 등 DBMS 제어용 명령어
-- grant, revoke
-- commit, rollback, savepoint (TCL, Transaction Control Language로 별도 분류하기도 함)

--system관리자계정으로 진행------------------------------------------------------------------------------
--qwerty계정 생성
create user qwerty
identified by qwerty
default tablespace users;

--접속권한 부여
--create session권한 또는 connect롤을 부여
grant connect to qwerty;
grant create session to qwerty;

--객체생성권한 부여
--create table, create index.....권한을 일일히 부여
--resource롤
grant resource to qwerty;

-------------system관리자계정 끝!------------------------------------------------------------------

--권한, 롤을 조회->qwerty 계정에서! 
select *
from user_sys_privs; --권한

select *
from user_role_privs; --롤

select *
from role_sys_privs; --부여받은 롤에 포함된 권한

--------------------------------------------------------
-- GRANT
--------------------------------------------------------
-- 권한, 롤(권한묶음)을 사용자에게 부여
-- grant [권한|롤] to [사용자|롤|PUBLIC] [with admin option]

-- public : dba관리자가 사용하는 것으로, 해당권한을 별도의 권한 획득없이 사용할 수 있도록 함.
-- with admin option : 권한을 부여받은 사용자가 다시 다른 사용자에게 권한을 부여할 수 있도록  함.

-- kh계정의 테이블 관련 권한 qwerty에게 부여하기

--커피테이블 생성
create table tb_coffee(
    cname varchar2(100),
    price number not null,
    brand varchar2(100) not null,
    constraint pk_tb_coffee_cname primary key(cname)
);

insert into tb_coffee values('maxim', 2000, '동서식품');
insert into tb_coffee values('kanu', 3000, '동서식품');
insert into tb_coffee values('nescafe', 2500, '네슬레');

-- oracle에서는 사용자 단위로 객체를 소유.
-- 사용자가 곧 스키마 schema(데이타베이스 구조를 나타내는 일종의 명세서)이다.
select * from tb_coffee; -- 접속 사용자의 tb_coffee를 조회

commit;

-- qwerty계정에서 tb_coffee 조회/열람 권한 부여
grant select on kh.tb_coffee to qwerty;

--SQL> column name format a30 크기 조절하는 명령어
--SQL> column brand format a30
--SQL> select * from kh.tb_coffee;

-- qwerty계정에서 tb_coffee 추가,수정,삭제 권한 부여
grant insert, update, delete on tb_coffee to qwerty;

--------------------------------------------------------
-- REVOKE
--------------------------------------------------------
-- 수정 권한 회수

revoke insert, update, delete on tb_coffee from qwerty; -- 조회는 가능함 
revoke select on tb_coffee from qwerty;--조회권한도 회수


--======================================================
-- Database Object 1
--======================================================
--DB를 효율적으로 관리하고 작동하게 하는 단위
-- Data Dictionary에서 객체 종류 조회

select * from all_objects;
select distinct object_type from all_objects;--중복제거하고 조회

--------------------------------------------------------
-- Data Dictionary
--------------------------------------------------------
-- 자원을 효율적으로 관리하기 위해 객체별 메타정보를 저장하는 관리자 테이블 
-- 일반 사용자 관리자로부터 열람권한을 얻어 사용하는 정보조회테이블
-- 사용자가 객체를 삽입, 수정, 삭제(객체관련작업)한다면 그 즉시 DD에 반영되는 구조
-- 사용자는 읽기전용으로 DD를 사용가능하다.

select * from dict order by 1;

-- DD의 종류 : ???_복수형객체명 user_tables, all_tables 처럼 객체명이 복수로 s가 들어감
-- 1. user_xxx : 사용자 소유의 객체에 대한 정보
-- 2. all_xxx : 사용자 소유 객체 포함, 다른사용자로부터 사용권한을 부여받은 객체에 대한 정보 
-- 3. dba_xxx : 관리자전용 소유 객체 (일반사용자 조회 불가) 모든 사용자의 모든 객체에 대한 정보 

--이용가능한 모든 dd조회
select * from dict;--dictionary

--*************************************************************************************
--user_xxx
--**************************************************************************************
--xxx는 객체이름 복수형을 사용한다. 

--user_tables
select * from user_tables;
select * from user_tabs;--위와 동의어(synonym)

--user_sys_privs : 권한
--user_role_privs : 롤 (권한묶음)
--role_sys_privs : 사용자가 가진 롤에 포함된 모든 권한

select * from user_sys_privs;
select * from user_role_privs;
select * from role_sys_privs;

--user_sequences
select * from user_sequences;
--user_views
select * from user_views;
--user_indexes
select * from user_indexes;
--user_constraints
select * from user_constraints;--유저 제약조건

select * from all_tables;

select * from dba_tables;

--*************************************************************************************
--all_xxx
--**************************************************************************************
--현재 계정이 소유하거나 사용권한을 부여받은 객체 조회

--all_tables
select * from all_tables;

--all_indexes
select * from all_indexes;

--*************************************************************************************
--dba_xxx
--**************************************************************************************

select * from dba_tables;--ORA-00942: table or view does not exist 일반사용자 접근 금지
                                        --접속계정을 system으로 하고 실행하면 보임 

--특정사용자의 테이블 조회
select * 
from dba_tables
where owner in ('KH','QWERTY');

--특정사용자의 권한 조회
select *
from dba_sys_privs
where grantee = 'KH';

--role 조회
select *
from dba_role_privs
where grantee = 'KH';

--테이블 관련 권한 확인
select *
from dba_tab_privs
where owner = 'KH';

--관리자가 kh.tb_coffee 읽기와 수정 권한을 qwerty에게 부여
grant select, insert, update, delete on kh.tb_coffee to qwerty;



--------------------------------------------------------
-- STORED VIEW
--------------------------------------------------------
-- 저장뷰
-- inlineview는 일회성이었지만 이를 객체로 저장해서 재사용이 가능.
-- 하나 이상의 테이블에서 원하는 데이터를 선택해서 새로운 가상테이블을 생성함.
-- 가상테이블처럼 사용하지만 조회의 목적을 가지며, 실제 데이터를 가지고 있는 것은 아니다
-- 실제 테이블과 링크개념.

--뷰객체를 이용해서 제한적인 데이터만 다른 사용자에게 제공하는 것이 가능하다.

-- create view 권한은 resource롤에 포함되지 않으므로, 관리자로부터 권한 부여가 필요하다.
-- or replace 옵션 제공 (table 제외하고 많은 객체에 지원함)

create view view_emp
as
select emp_id,
            emp_name,
            substr(emp_no, 1, 8) || '******' emp_no,
            email, 
            phone
from employee;

--drop view view_emp;

--create view 권한을 부여받아야 한다.

--테이블처럼 사용
select * from view_emp;-> 링크개념 


select *
from (
select emp_id,
            emp_name,
            substr(emp_no, 1, 8) || '******' emp_no,
            email, 
            phone
from employee
);
--dd에서 조회
select * from user_views;

select *
from view_emp;

-- inline_view처럼 작동
select *
from (select emp_id,
       emp_name,
       substr(emp_no, 1, 8) || '******' emp_no,
       decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') gender
       from employee);

-- DD에서 조회
select *
from user_views
where view_name = 'VIEW_EMP';

-- 타사용자에게  선별적인 데이터를 제공 (view 권한 부여)

grant select on view_emp to qwerty;

--view특징
--1. 실제 컬럼뿐 아니라 가공된 컬럼 사용가능
--2. join을 사용하는 view 가능
--3. or replace 옵션 사용가능 
--4. with read only 옵션-> 조회만 가능하게


create or replace view view_emp
as
select emp_id,
       emp_name,
       substr(emp_no, 1, 8) || '******' emp_no,
       email,
       phone,
       nvl(dept_title,'인턴') as dept_title
from employee E
    left join department D
        on E.dept_code = D.dept_id
        with read only;

--성별, 나이등 복잡한 연산이 필요한 컬럼을 미리 view지정해두면 편리하다.
create or replace view view_employee_all
as
select E.*,
            decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') gender
from employee E;

select *
from view_employee_all
where gender = '여';



--------------------------------------------------------
-- SEQUENCE
--------------------------------------------------------
-- 정수값을 순차적으로  자동생성하는 객체. 채번기
/*
create sequence 시퀀스명
[start with 시작값]--------------------기본값 1
[increment by 증감값]-----------------기본값 1
[maxvalue(최대 한계치) 숫자 | nomaxvalue(무한 증가)]------------기본값 nomaxvalue, 최대값에 도달하면 다시 시작값(cycle) 혹은 에러(nocycle)
[minvalue(최소 한계치) 숫자 | nominvalue(무한 감소)]-------------기본값 nominvalue, 최소값에 도달하면 다시 시작값(cycle) 혹은 에러(nocycle)
[cycle | nocycle] --------------순환여부,기본값 npocycle, 최대/최소값에 도달하면 순환. nocycle 선택시는 max/min value 도달시 오류 발생
[cache 캐싱갯수 | nocache] -------- 메모리상에서 시퀀스값을 관리. 기본값은 cache 20. 시퀀스객체로 부터 20개씩 가져와서 메모리에서 채번. 
                                                       오류가 발생하여 숫자를 건너뛸수도 있다. 번호유실이 문제된다면 nocache로 사용할 것
    * CACHE | NOCACHE : CACHE 여부, 원하는 숫자만큼 미리 만들어 Shared Pool의 Library Cache에 상주시킨다.
*/

create table tb_names(
    no number,            --회원고유번호
    name varchar2(100) not null,
    constraint pk_tb_names_no primary key(no)
);

-- 시퀀스 생성

create sequence seq_tb_names_no
start with 1000 --1000부터 시작
increment by 1 --1씩 증가
nomaxvalue --최대값 없음
nominvalue --최소값 없음
nocycle --순환하지 않음
cache 20;

insert into tb_names
values(seq_tb_names_no.nextval, '홍길동');

select * from  tb_names;

-- 시퀀스 객체의 value 확인
select seq_tb_names_no.currval--시퀀스객체의 현재번호
from dual;

select seq_tb_names_no.nextval--계속 1씩 증가한다.
from dual;

-- DD에서 확인
select * from user_sequences;
-- 여기서 LAST_NUMBER 컬럼은 다음에 가져갈 첫 번호를 의미하는 것

--복합문자열에 시퀀스 사용하기
--주문번호 kh-20210205-1001

create table tb_order(
     order_id varchar2(50),
     cnt number,
     constraints pk_tb_order_id primary key(order_id)
     );

create sequence seq_order_id;--기본값으로 생성

insert into tb_order
values('kh-' || to_char(sysdate, 'yyyymmdd') || '-' || to_char(seq_order_id.nextval,'FM0000'), 100);

select * from tb_order;

--alter문을 통해 시작값 start with값은 절대 변경할 수 없다. 그때 시퀀스 객체 삭제 후 재생성 할 것.

alter sequence seq_order_id increment by 10; -- 이건 가능함 


/*
[캐싱이란]
알뜰살뜰하게 가지고 있는 일종의 저장 공간

이미지 a,b,c,가 있는데 F5키를 눌러 새로고침을 했다.
새로고침 전과 정보는 똑같은데 굳이 서버에 가서 이미지를 또 받아올까?
그렇지 않다, 똑같은 자원이므로 브라우저의 내부에서 캐싱(저장)을 해 둔다.
파일에 변화가 없다면 캐싱된 데이터를 사용하게 된다.

분명 한번만 NEXTVAL을 통해서 번호를 받았지만, 
DataDictionary에 있는 LAST_NUMBER값은 21로 되어 있습니다. 
이는 CACHE_SIZE가 기본 20이기 때문입니다.

오라클 서버가 실행되면 SGA 공유메모리에 SEQUENCE의 CACHE_SIZE만큼 미리 번호를 생성합니다. 
홈쇼핑이나 주식과 같이 많은 양의 Transaction이 발생되는 업무에서 
한번에 많은 프로세스가 SEQUENCE를 접근시 빠른 속도로 대응하지 못하는 것을 방지하기 위해 
공유메모리에 번호를 미리 생성해줍니다. 
CACHE의 SIZE는 Sequence생성 시 정할 수 있습니다.
*/

-- 주문 전표 생성
-- kh-210104-1234
create table tb_order (
    order_no varchar2(100),
    user_id varchar2(50) not null,
    product_id varchar2(100) not null,
    cnt number default 1 not null,
    order_date date default sysdate,
    constraint pk_tb_order_no primary key(order_no)
);

create sequence seq_tb_order_no
nocache;

--kh-210104-0001
insert into tb_order
values(
    'kh-' || to_char(sysdate, 'yymmdd') || '-' || to_char(seq_tb_order_no.nextval, 'fm0000'),
    'honggd',
    '아이폰12',
    2,
    default
);

select * from tb_order;
rollback;

select * from user_sequences;

select * from tb_order;

-- pl/sql -> procedure | function | trigger

--------------------------------------------------------
-- INDEX
--------------------------------------------------------
-- 색인
-- sql조회구문등의 처리속도 향상을 위해서 테이블 컬럼에 대해 생성하는 객체
-- key-value형식으로 생성. key에는 컬럼값, value에는 행에 접근할 수 있는 주소값이 저장
--key: 컬럼값, value:레코드논리적주소값 rowid
--저장하는 데이터에 대한 별도의 공간이 필요함.(view와 다른점!)

-- [장점]
-- 검색속도가 빨라지고, 시스템 부하를 줄일 수 있다.
-- table-full-scan하지 않고, index에서 먼저 검색 후 행을 조회

-- [단점]
-- 인덱스 저장공간 필요, 인덱스를 생성, 갱신하는데도 별도의 부가적인 시간이 걸린다.
-- 변경작업(insert / update / delete)이 많다면, 
-- 실제 데이터 처리 + 인덱스 갱신 시간이 소요되어 성능 저하 유발 우려

-- 단순조회업무보다 변경작업(insert/update/delete)가 많다면 index생성을 주의해야한다.

-- 인덱스 생성 시, 어떤 컬럼을 선택해야 하는가?
-- 선택도(selectivity)가 좋은 컬럼으로 생성
-- (선택도가 좋다는 것은 중복값이 적다는 의미)
--1. 선택도 좋다 : emp_id, emp_no, email, emp_name(동명이인이 있을 수 있지만, 중복값이 적은 편이니), ...
--2. 선택도 나쁘다 : 성별, dept_code, ... 혹은 null값이 많은 컬럼
-- DD에서 조회
-- pk, uq 제약조건이 걸린 컬럼은 자동으로 index를 생성해준다.--삭제하려면 제약조건을 삭제해야함.
--3. where절에 자주 사용되어지는 경우, 조인기준컬럼인 경우 
--4. 입력된 데이터의 변경이 적은 컬럼 

select *
from user_indexes
where table_name = 'EMPLOYEE';

--실행계획(f10)을 통한 query비용 비교
--1. 인덱스를 통하지 않은 조회
--job_code 인덱스가 없는 컬럼
select * from employee where job_code = 'J1'; --table full scan
select * from employee where emp_name = '송종기';

--2. 인덱스를 사용한 조회
select * from employee where emp_id = '201'; --unique scan -> by index rowid 인덱스가 있으면 비용이 훨씬 적게 든다.


--emp_name 조회
select *
from employee
where emp_name ='송종기';

-- emp_name 컬럼에 인덱스 추가생성
create index idx_employee_emp_name
on employee(emp_name);

--인덱스 적용하기
--1. where 조건절에 자주 사용되는 컬럼은 인덱스 생성
--   (선택도가 좋지 않더라도)
--2. join 기준컬럼은 인덱스 생성
--3. 한번 입력후에 데이터변경이 많지 않은 경우
--4. 데이터가 20만~50만건 이상인 경우.

-- 인덱스 사용시 주의사항
-- optimizer가 index사용 여부를 결정하며, 다음 경우는 인덱스를 사용하지 않는다.
--1. 인덱스컬럼에 변형이 가해진 경우, substr(emp_no,8,1)이런거 (substr사용)
--2. null 비교
--3. not 비교 검색
--4. index컬럼 자료형과 비교하고자 하는 값의 타입이 다른 경우

--4번 살펴보기(1) | char를 number로 보내버렸음
select * from employee where emp_id = '200'; --uniq scan
select * from employee where emp_id = 200; --full

--4번 살펴보기(2) | 컬럼에 substr로 인해 변형이 가해졌음
select * from employee where emp_no = '621225-1985634'; --uniq scan
select * from employee where substr(emp_no, 8, 1) = '1'; --full
select * from employee where emp_no like '______-1______'; --full
