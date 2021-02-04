--======================================================
-- DML
--======================================================
--Data Manipulation Language 데이터 조작어
--테이블의 데이터를 삽입 create, 조회 read, 수정 update, 삭제 delete하기 위한 명령어 : CRUD

--crud :Create Retrieve update delete 테이블 행에 대한 명령어
--insert : 행추가
--select : (DQL)
--update : 행수정
--delete : 행삭제

--------------------------------------------------------
-- INSERT
--------------------------------------------------------
--새로운 행을 추가하는 명령어

--1. insert into 테이블 values(데이터(컬럼)1, 데이터(컬럼)2,...); 모든 컬럼을 빠짐없이 순서대로 작성해야함
--테이블에 존재하는 컬럼 순서대로 데이터를 추가. 생략할 수 없다.

--insert into 테이블(컬럼1, 컬럼2, ...) values (데이터(컬럼)1, 데이터(컬럼)2, ...); 컬럼을 생략가능, 컬럼순서도 자유롭다.
--행추가시 테이블 컬럼중 일부를 선택적으로 지정해 값을 대입한다.
--단 not null 컬럼은 생략할 수 없다.
--단 not null이어도 기본값이 지정되면 생략할 수 있다.

--emp_copy 테이블 생성
create table dml_sample(
id number,
nick_name varchar2(100) default '홍길동',
name varchar2(100) not null,
enroll_date date default sysdate not null
);
select * from dml_sample;

--타입1
insert into dml_sample
values(100, default,'신사임당',default);

insert into dml_sample
values(100, default,'신사임당');--ORA-00947: not enough values

insert into dml_sample
values(100, default,'신사임당',default, 'ㅋㅋ');--SQL 오류: ORA-00913: too many values

--타입2: 장점은 원하는 컬럼만 골라쓸수있다는 점 
insert into dml_sample(id,nick_name,name,enroll_date)
values(200,'제임스','이황',sysdate);

insert into dml_sample(name,enroll_date)
values('세종',sysdate);--nullable한 컬럼은 생략가능하다. 기본값이 있다면 기본값이 적용된다.

--not null이면서 기본값이 지정안된경우 생략할 수 없다.
insert into dml_sample(id,enroll_date)
values(300,sysdate);--오류 보고 ORA-01400: cannot insert NULL into ("KH"."DML_SAMPLE"."NAME")

insert into dml_sample(name)
values('이현재');

--서브쿼리를 이용한 insert

create table emp_copy
as
select *
from employee
where 1 = 2; -- 테이블구조만 복사해서 테이블을 생성

select * from emp_copy;

insert into emp_copy(
select *
from employee
);

rollback;--전체삭제

insert into emp_copy(emp_id,emp_name, emp_no, job_code, sal_level)(
select emo_id,emp_name, emp_no, job_code, sal_level
from employee
);

--emp_copy 데이터 추가
select * from emp_copy;

--기본값 확인 data_default
select *
from user_tab_cols
where table_name = 'EMP_COPY';--컬럼정보 확인 구문

--기본값 추가
alter table emp_copy--테이블 수정
modify quit_yn default 'N'
modify hire_date default sysdate;


 --1. 컬럼명 없이 데이터 추가하기
insert into emp_copy 
values(
        '201', '이현재', '970913-1123456', 'now@kh.or.kr', '01012341234',
        'D1', 'J2', 'S3', 3300000, 0.1, '200', sysdate, null, 'N'
        );
        
       
--2. 컬럼명과 함께 데이터 추가하기
insert into emp_copy
(emp_id, emp_name, emp_no, job_code, sal_level)
values(
        '302', '구술기', '900909-2345678', 'J5', 'S4'
);

select * from emp_copy;
desc emp_copy;


--서브쿼리를 이용한 테이블생성에서는 not null을 제외한 제약조건, 기본값등이 누락된다.

--insert all을 이용한 여러테이블에 동시에 데이터 추가
--한 테이블 데이터를 복수개의 테이블에 추가하는 경우
--서브쿼리를 이용해서 2개이상 테이블에 데이터를 추가, 조건부 추가도 가능 

--입사일 관리 테이블
create table emp_hire_date
as
select emp_id, emp_name, hire_Date 
from employee
where 1 = 2; --모든 행에 대하여 무조건 false라서 테이블의 구조만 복사되고 데이터는 복사하지 않는 방법

--매니져 관리 테이블
create table emp_manager
as
select emp_id, 
            emp_name, 
            manager_id, 
            emp_name manager_name 
from employee
where 1 = 2; --모든 행에 대하여 무조건 false라서 테이블의 구조만 복사되고 데이터는 복사하지 않는 방법

select * from emp_hire_date;
select * from emp_manager;

--manager_name을 null로 변경
alter table emp_manager
modify manager_name null;


--from테이블과 to테이블의 컬럼명이 같아야 한다.
insert all
into emp_hire_date values(emp_id, emp_name, hire_date)
into emp_manager values(emp_id, emp_name, manager_id, manager_name)
select E.*,
(select emp_name from employee where emp_id = E.manager_id) manager_name
from employee E;

--insert all을 이용한 여러행 한번에 추가하기
--insert into dml_sample values(1,'치킨', '홍길동'), (2,'고구마', '장발장'),(3,'피자', '이현재');--오라클에서 지원하지 않는 문법

insert all
into dml_sample values(1,'치킨', '홍길동',default)
into dml_sample values(2,'피자', '이현재',default)
into dml_sample values(3,'콜라', '전정국',default)
select * from dual; --더미쿼리


--------------------------------------------------------
-- UPDATE
--------------------------------------------------------
--기존레코드의 컬럼 일부를 수정하는 명령
--where 조건절을 정확히 지정할 것.
--update실행후에 행의 수에는 변화가 없다.
--0행, 1행이상을 동시에 수정한다.
--dml 처리된 행의 수를 반환.

select * from emp_copy;



update emp_copy
set dept_code = 'D8'
--where emp_id = '2002';--0개 행 이(가) 업데이트되었습니다.
where emp_id = '201';



update emp_copy
set dept_code = 'D2', job_code = 'J2'
where emp_id = '201';

rollback;--마지막 커밋시점으로 돌리기
commit;--메모리상 변경내역을 실제파일에 저장

update emp_copy
set salary = salary + 500000-- + = 복합대입연산자는 사용불가
where dept_code = 'D2';

--서브쿼리를 이용한 update
--방명수 사원의 급여를 유재식사원과 동일하게 수정
update emp_copy
set salary = (select salary from emp_copy where emp_name = '유재식')
where emp_name = '방명수';--138만원에서 340만원으로 바뀜 

commit;


-- emp_copy의 데이터를 employee로부터 채우고,
-- 임시환 사원의 직급을 과장, 부서를 해외영업 3부로 수정
-- 방명수 사원을 삭제하세요.

insert into emp_copy(
            select * from employee
);

select * from emp_copy;
select * from job; -- J5
select * from department; -- D7

update emp_copy
set job_code = (select job_code from job where job_name = '과장'),
    dept_code = (select dept_id from department where dept_title = '해외영업3부')
where emp_name = '임시환';

commit;
rollback;

update emp_copy
set emp_name = '홍길동'; -- 전부 홍길동으로 바뀐다 !! 주의 

select * from emp_copy;


rollback;

--------------------------------------------------------
-- DELETE
--------------------------------------------------------
-- 테이블의 행(레코드)를 삭제
-- where절을 정확히 작성할 것

delete from emp_copy
where emp_id = '211';

select * from emp_copy;
commit;

--delete from emp_copy; --모든 행을 삭제! 주의!!
rollback;--가능하다.

------------------------------------------------------------
--truncate
------------------------------------------------------------
--테이블 전체행을 삭제. 
--DDL 명령어(create, alter, drop, truncate). 자동 commit된다. rollback이 안된다.
--before image생성작업 없기떄문에.
--장점은 실행속도가 빠름.

truncate table emp_copy;

select * from emp_copy;

--다시넣기
insert into emp_copy
(select * from employee);


--======================================================
-- DDL
--======================================================
-- Data Definition Language =데이터 정의어
-- 데이터베이스 객체에 대해서 생성 create, 수정 alter, 삭제 drop할수 있는 명령어모음

-- 객체종류 : table | view | sequence| index | package | procedure | function | trigger | synonym |scheduler| user...
-- 자동으로 commit 되므로 주의해서 실행할 것

--주석 comment
--테이블, 컬럼에 대한 주석을 달 수 있다.(필수)

select*
from user_tab_comments;

select *
from user_col_comments
where table_name = 'EMPLOYEE';

select *
from user_col_comments
where table_name = 'DEPARTMENT';

select *
from user_col_comments
where table_name = 'TBL_FILES';

desc tbl_files;

--테이블주석
comment on table tbl_files is '파일경로테이블';

--컬럼주석
comment on column tbl_files.fileno is '파일 고유번호';
comment on column tbl_files.filepath is '';--빈 문자열은 null과 동일 

--수정/삭제 명령은 없다.
--...is ''; 삭제

--======================================================
--제약조건 CONSTRAINT
--======================================================
--테이블 생성 수정시에 각 컬럼에 대해서 제약조건을 설정할수 있다.
--데이터에 대한 무결성 intergrity를 보장하기 위한것.
--무결성은 데이터를 정확하고 일관되게 유지하는것



--1. not null (C): 데이터에 null을 허용하지 않음 -> 필수값
--2. unique (U): 중복된 값을 허용하지 않음
--3. primary key (P) : 행(레코드)의 식별자 컬럼을 지정. not null + unique, 테이블당 한개 사용가능 
--                 -> 아이디, 고유코드
/*
emp_id를 기본키로 지정했다 치면, 
이 emp_id는 다른 사람과 무조건 달라야된다는거고 무조건 한 개의 값만 존재하니까 
이거로 행을 구분할 수 있게 되는거임. null값을 가질 수 없고, 테이블 당 기본키는 무조건 하나만 존재
*/
--4. foreign key (R): 외래키. 두 테이블간의 부모자식 참조관계를 설정.
--                            데이터 참조무결성 보장.
--                             부모테이블에 존재하는 값만 자식테이블에서 사용가능                  
--5. check (C): domain 안에서만 값을 설정하도록함. -> 성별, 퇴사여부, 점수
                    --저장 가능한 값의 범위/조건을 제한
                    
--일절 허용하지 않음

--제약조건 확인
--Data Dictionary

--user_constraints(컬럼명이 없음)
--user_cons_columns

--1
select *
from user_constraints
where table_name = 'EMPLOYEE';
--컬럼 확인이 안된다는 게 단점

--C check  |  not null
--U Unique
--P primary key
--R foreign key


--2. 컬럼명 확인
select *
from user_cons_columns
where table_name = 'EMPLOYEE';

--보통은 조인해서 사용함
--제약조건 검색
select constraint_name,
            uc.table_name,
            ucc.column_name,
            uc.constraint_type,
            uc.search_condition
from user_constraints UC
        join user_cons_columns UCC
   using(constraint_name) 
where UC.table_name = 'EMPLOYEE';

--------------------------------------------------------
-- NOT NULL | UNIQUE
--------------------------------------------------------
--필수입력 컬럼에 not null제약조건을 지정한다.
--default값 다음에 컬럼레벨에 작성한다.
--보통 제약조건명을 지정하지 않는다.
create table tb_cons_nn(
id varchar2(20) not null, -- 컬럼레벨
name varchar2(100)
--테이블레벨
);

insert into tb_cons_nn values (null, '홍길동');--오류 보고 -ORA-01400: cannot insert NULL into ("KH"."TB_CONS_NN"."ID")
insert into tb_cons_nn values ('honggd', '홍길동');

select * from tb_cons_nn;
update tb_cons_nn
set id = ''
where id = 'honggd'; --ORA-01407: cannot update ("KH"."TB_CONS_NN"."ID") to NULL


--제약조건 작성 방법
--1. 컬럼레벨 : 컬럼명 기술한 같은 줄에 작성. not null은 컬럼레벨만 작성 가능
--2. 테이블레벨 : 별도의 줄에 작성
-- 되도록 테이블레벨로 작성할 것.
-- 제약조건명은 반드시 작성할 것. (not null 제외)
------------------------------------------------------------
--UNIQUE
------------------------------------------------------------
--이메일, 주민번호, 닉네임
--전화번호는 UQ 사용하지 말것.
--중복 허용하지 않음.

create table tb_cons_uq(
no number not null,--컬럼레벨
email varchar2(50),
--테이블레벨
constraint uq_email unique(email)
);

insert into tb_cons_uq values(1,'abc@naver.com');
insert into tb_cons_uq values(2,'가나다@naver.com');
insert into tb_cons_uq values(1,'abc@naver.com');--ORA-00001: unique constraint (KH.UQ_EMAIL) violated 유니크제약위반 
insert into tb_cons_uq values(4,null);-- null은 허용

select * from tb_cons_uq;


--unique 제약조건이 걸려있어도 null값은 여러번 입력 가능하다.
--dbms마다 처리방식이 다르다. mssql에서는 딱 한번만 입력 가능
insert into member
values ('sinsa', '1234', '신사임당', null, '01012341234');
-- ORA-01400: cannot insert NULL into ("KH"."MEMBER"."EMAIL")

--제약조건 조회

select UC.table_name, 
       UCC.column_name, 
       UC.constraint_name,
       UC.constraint_type,
       UC.search_condition
from user_constraints UC join user_cons_columns UCC
     on UC.constraint_name = UCC.constraint_name
where UC.table_name = 'MEMBER';

select * from member;

--------------------------------------------------------
-- PRIMARY KEY
--------------------------------------------------------
--테이블(레코드) 행에 대한 고유 식별자 역할을 하는 제약조건
--not null + unique 기능을 가지고 있다.
--다른 행(레코드) 구분하기위한 용도. 중복 또는 null을 허용하지 않는다.
--테이블당 한개만 가능

--drop table shop_buy;
create table tb_cons_pk (
    id varchar2(50),
    name varchar2(100) not null, --not null은 컬럼레벨에서 추가
    email varchar2(200),  
    constraint pk_id primary key(id),
    constraint uq_email2 unique (email) 
);

insert into tb_cons_pk
values('honggd', '홍길동','hgd@google.com');

--ORA-00001: unique constraint (KH.PK_ID) violated 같은걸로 한번 더 추가 하면 뜨는 에러

insert into tb_cons_pk
values(null, '홍길동','hgd@google.com');--ORA-01400: cannot insert NULL into ("KH"."TB_CONS_PK"."ID") null쓸수 없다.

select * from tb_cons_pk;

--제약조건 검색
select constraint_name,
            uc.table_name,
            ucc.column_name,
            uc.constraint_type,
            uc.search_condition
from user_constraints UC
        join user_cons_columns UCC
   using(constraint_name) 
where UC.table_name = 'TB_CONS_PK';


--복합 기본키(주키| primary key | pk)
--여러 컬럼을 조합해서 하나의 PK로 사용.
--사용된 컬럼 하나라도 null이어서는 안된다.

create table tb_order_pk(
        user_id varchar2(50), 
        order_date date,
        amaount number default 1 not null,
        constraint pk_user_id_order_date primary key(user_id, order_date)
);

insert into tb_order_pk
values('honggd', sysdate, 3);--시분초 다르게 계속 들어감.


insert into tb_order_pk
values(null, sysdate, 3);--ORA-01400: cannot insert NULL into ("KH"."TB_ORDER_PK"."USER_ID") null값 안됨


select user_id,
            to_char(order_date, 'yyyy/mm/dd hh24:mi:ss') order_date,
            amount
from tb_order_pk;

select *
from tb_order_pk;


--------------------------------------------------------
-- FOREIGN KEY
--------------------------------------------------------
--외래키. 참조무결성을 보장
--참조하고 있는 부모테이블에서 제공하는 지정 컬럼값만 사용하도록 제한함.
--자식테이블의 컬럼에 외래키 제약조건을 설정하는 것.
--자식테이블에서는 부모테이블의 값 또는 null값을 사용 가능.
--부모테이블의 참조컬럼은 반드시 pk, uq제약조건이 걸려있어야함.
--department.dept_id(부모테이블) <------ employee.dept_code(자식테이블)


select * from department;
select * from employee;

--drop table shop_member;
create table shop_member (
   member_id varchar2(20),
    member_name varchar2(30) not null,
    constraint pk_shop_member_id primary key(member_id)
                                                
);

insert into shop_member values('honggd', '홍길동');
insert into shop_member values('sinsa', '신사임당');
insert into shop_member values('sejong', '세종');

select * from shop_member;
commit;

--상품구매테이블

--drop table shop_buy;
create table shop_buy (
    buy_no number,
    member_id varchar2(20),
    product_id varchar2(50),
    buy_date date default sysdate,
    constraints pk_shop_buy_no primary key(buy_no),
    constraints fk_shop_buy_member_id foreign key(member_id)
                                     references shop_member(member_id)
                                  
                                     on delete cascade
);

--샵 멤버가 부모 샵 바이가 자식 

insert into shop_buy values (1, 'honggd', 'soccer_shose', default);
insert into shop_buy values (2, 'aaabbb', '축구화');
--ORA-02291: integrity constraint (KH.FK_SHOP_BUY_MEMBER_ID) violated - parent key not found
insert into shop_buy values (2, 'sinsa', 'basketball_shose',default);


select * from shop_member;
select * from shop_buy;

--fk기준으로 join->relation
--구매번호 회원아이디 회원이름 구매물품아이디 구매시각

select B.buy_no 구매번호,
            member_id 회원아이디,
            M.member_name 회원이름,
            B.product_id 물품아이디,
            B.buy_date 구매시각
from shop_member M
    join shop_buy B
        using(member_id);
        

--정규화 normalization
--이상현상 방지(anormaly)
select *
from employee;

select *
from department;


--shop_member 참조되고 있는 회원을 삭제

delete from shop_buy
where member_id = 'honggd';

delete from shop_member
where id = 'honggd';

--ORA-02292: integrity constraint (KH.FK_SHOP_BUY_MEMBER_ID) violated - child record found

-- fk의 삭제옵션
-- 부모테이블의 행을 삭제할 때, 참조하고 있는 자식테이블 행에 대한 처리
-- 1. on delete restricted(기본값) - 자식테이블 참조행이 있는 경우, 부모행 삭제 불가
--                                                 자식행 삭제 후에 부모행 삭제
-- 2. on delete set null - 부모행 삭제 시, 자식테이블 컬럼값을 null로 변환
-- 3. on delete cascade - 부모행 삭제 시, 자식테이블 행도 함께 삭제


delete from shop_member
where member_id = 'honggd'; --ORA-02292: integrity constraint (KH.FK_SHOP_BUY_MEMBER_ID) violated - child record found
                                                --참조하고 있는 자식행이 있는데 부모행을 지우면 안된다. 자식행삭제 먼저하고 부모행 삭제해야함
                                                
delete from shop_buy
where member_id = 'honggd';

delete from shop_member
where member_id = 'honggd';

--이렇게 하면 둘다 삭제된다.


-- 2. on delete set null 옵션 변경하고  지우는 구문
delete from shop_member
where id = 'sinsa';

-- 3. on delete cascade 옵션 변경하고 지우는 구문
delete from shop_member
where id = 'sinsa';

--외래키 -> 식별관계 | 비식별관계
-- 1. 식별관계 : 참조하는 컬럼값(pk, uq)을 자식테이블에서 pk로 사용하는 경우. 중복사용이 안됨. 부모행과 자식행 사이에 1:1관계 
-- 2. 비식별관계 : 참조하는 컬럼값(pk, uq)을 자식테이블에서 pk로 사용하지 않는 경우. 여러행에서 참조가 가능(중복) 물건을 여러개 살수있음. 1:n관계
--                shop_member.id -> shop_buy.member_id(pk가 아니다)

--식별관계
create table shop_nickname(
member_id varchar2(20),
nickname varchar2(100),
constraints fk_member_id foreign key(member_id) references shop_member(member_id),
constraints pk_member_id primary key(member_id)
);

select * from shop_nickname;

insert into shop_nickname
values('sinsa', '신솨112');

select * from shop_nickname;


--------------------------------------------------------
-- CHECK
--------------------------------------------------------
-- 도메인(컬럼이 취할 수 있는 값의 집합)을 제한
-- yes/no, t/f, 1/0, G/S/V, 0~100
-- null 허용

--drop table tb_cons_ck
   create table tb_cons_ck(
     gender char(1),
num number,
constraints ck_gender check(gender in ('M', 'F')),
constraints ck_num check(num between 0 and 100)
);

insert into tb_cons_ck
values('M', 50);
insert into tb_cons_ck
values('F', 100);
insert into tb_cons_ck
values('m', 50);--ORA-02290: check constraint (KH.CK_GENDER) violated 소문자는 안된다.
insert into tb_cons_ck
values('F', 1000); --ORA-02290: check constraint (KH.CK_NUM) violated 제약조건을 넘어서 안된다.

create table member (
    id varchar2(20) not null,
    password varchar2(20) not null,
    name varchar2(50) not null,
    email varchar2(100) not null, --not null은 컬럼레벨에서 추가
    phone char(11) not null,
    gender char(1),
    point number,
    constraint pk_member_id primary key(id),
    constraint uq_member_email unique (email),
    constraint ck_member_gender check(gender in ('M', 'F')),
    constraint ck_member_point check(point between 0 and 100)
);    

--옳은 예
insert into member
values (
    'honggd', '1234', '홍길동', 'hgd@naver.com', '01012341234',
    'M',
    90
);

--잘못된 예
insert into member
values (
    'sinsa', '1234', '신사임당', 'sinsa@naver.com', '01012341234',
    'm', --여기 혹은(chcek gender)
    190 --여기를 잘못쓰면(check point)
);
-- ORA-02290: check constraint (KH.CK_MEMBER_POINT) violated

select * from member;
