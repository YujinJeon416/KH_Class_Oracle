--@실습문제 : tb_number테이블에 난수 100개(0~999)를 저장하는 익명블럭을 생성하세요.
--실행시마다 생성된 모든 난수의 합을 콘솔에 출력할 것.

        
        create table tb_number(
    id number, --pk sequence객체로 부터 채번
    num number, --난수
    reg_date date default sysdate,
    constraints pk_tb_number_id primary key(id)
);
create sequence seq_tb_nubmer_id;
 --insert문 실행.
declare
    rnd number;
    v_sum number := 0;
begin
    for n in 1..100 loop
        --난수 생성
        rnd := trunc(dbms_random.value(0,1000));
        -- 데이터 추가
        insert into tb_number (id, num) 
        values(seq_tb_nubmer_id.nextval, rnd);
        --누적합
        v_sum := v_sum + rnd;
    end loop;
    
    dbms_output.put_line('합계 : '||v_sum);
    --트랜잭션처리
    commit;
end;
/
--데이터확인
select * from tb_number;
--데이터제거
--truncate table tbl_number;

--=================================================
--DATABASE OBJECT2
--=================================================
--PL/SQL문법을 사용하는 객체


----------------------------------------------------------------
--FUNCTION
----------------------------------------------------------------

--문자열 앞뒤에 d...b 헤드폰 씌우기 함수
--매개변수, 리턴선언시 자료형의 크기 지정하지 말것.

create or replace function db_func (p_str varchar2)
return varchar2
is
        --사용할 지역변수 선언
        result varchar2(32767);
begin
        --실행로직
        result := 'd' || p_str || 'b';
        return result;
end;
/

--실행
--1.일반 sql문
select db_func(emp_name)
from employee;

--2. 익명블럭/다른 pl/sql객체에서 호출가능
set serveroutput on;
begin
    dbms_output.put_line(db_func('&이름'));
end;
/

--3.exec | execute 프로시져/함수 호출하는 명령
var text varchar2;
exec :text := db_func('신사임당');
print text;

--Data Dictionary에서 확인

select * 
from user_procedures
where object_type='FUNCTION';

--성별구하기 함수
create or replace function fn_get_gender(
    p_emp_no employee.emp_no%type
)
return varchar2
is
    gender varchar2(3);
begin
--    if substr(p_emp_no, 8, 1) in ('1', '3') then
--        gender := '남';
--    else 
--        gender := '여';
--    end if;
--type1 : when조건식을 여러개 나열
--    case 
--        when substr(p_emp_no, 8, 1) in ('1', '3') then
--            gender := '남';
--        else
--            gender := '여';
--    end case;

--type2 :decode와 비슷, 단하나의 계산식만 제공.
case substr(p_emp_no,8,1)
when '1'then gender := '남';
when '3' then gender := '남';
else gender := '여';
end case;

    return gender;
end;
/

--주민번호를 입력받아 나이를 리턴하는 함수 fn_get_age를 작성하고
--사번, 사원명, 주민번호, 성별, 나이 조회(일반 sql문)


create or replace function fn_get_age(
                p_emp_no employee.emp_no%type
)
return number
is
    v_age number;
    v_birth_year number;
begin
    case 
        when substr(p_emp_no, 8, 1) in ('1', '2')  then v_birth_year := 1900;
          when substr(p_emp_no, 8, 1) in ('3', '4')  then v_birth_year := 2000;
       
    end case;
    v_birth_year := v_birth_year + substr(p_emp_no, 1,2); --출생년도
    
    v_age := extract(year from sysdate) - v_birth_year +1;
    return v_age;
end;
/
select emp_id 사번,
            emp_name 이름,
            emp_no 주민번호,
            fn_get_gender(emp_no) 성별,
            fn_get_age(emp_no) 나이
from employee;

-----------------------------------------------------------
--PROCEDURE
-----------------------------------------------------------
--함수와 달리 리턴값이 없다.
--OUT매개변수를 사용하면 호출부쪽으로 

--1.매개변수 없는 프로시져
select * from member;

create or replace procedure proc_del_member
is
    --지역변수 선언
begin
        --실행구문
        delete from member;
        commit;
end;
/

--a. 익명블럭 | 타 프로시져 객체에서 호출가능
begin
    proc_del_member;
end;
/


--b. execute 명령

 execute proc_del_member;
 
 --DD에서 확인
 
 select *
 from user_procedures
 where object_type = 'PROCEDURE';
 
 select *
 from user_source
 where name = 'PROC_DEL_MEMBER';
 
 
--2. 매개변수 있는 프로시져
--매개변수의 mode 기본값 in
create or replace procedure proc_del_emp_by_id(
        p_emp_id emp_copy.emp_id%type
)
is
begin
        delete from emp_copy
        where emp_id = p_emp_id;
        commit;
        dbms_output.put_line(p_emp_id || '번 사원을 삭제했습니다.');
end;
/

select * from emp_copy;

begin
    proc_del_emp_by_id('&삭제할_사번');
end;
/


-- IN/OUT 매개변수 사용하기: 프로시저 내부에서 사용될 변수
-- IN 매개변수: 프로시저 내부에서 사용될 변수
-- OUT 매개변수: 프로시저 외부(호출부)에서 사용될 변수
-- 사용자가 입력한 사번으로 사원명, 전화번호를 리턴(out매개변수)하는 프로시저
create or replace procedure proc_select_emp_by_id(
    p_emp_id in emp_copy.emp_id%type,
    p_emp_name out emp_copy.emp_name%type,
    p_phone out emp_copy.phone%type
)
is 
begin
    select emp_name, phone
    into p_emp_name, p_phone
    from emp_copy
    where emp_id = p_emp_Id;
end;
/

--익명블럭 호출(client)
declare
    v_emp_name emp_copy.emp_name%type;
    v_phone emp_copy.phone%type;
begin
    proc_select_emp_by_id('&사번', v_emp_name, v_phone);
    dbms_output.put_line('v_emp_name : ' || v_emp_name);
    dbms_output.put_line('v_phone : ' || v_phone);
end;
/

--upsert 예제 : insert + update
create table job_copy
as
select * from job;

select * from job_copy;

--pk제약조건, not null추가
alter table job_copy
add constraints pk_job_copy primary key(job_code)
modify job_name not null;

--직급정보를 추가하는 프로시져
create or replace procedure proc_man_job_copy(
    p_job_code in job_copy.job_code%type,
    p_job_name in job_copy.job_name%type
)
is
    v_cnt number := 0;
begin
    --1. 존재여부 확인
    select count(*)
    into v_cnt
    from job_copy
    where job_code = p_job_code;
    
    dbms_output.put_line('v_cnt = ' || v_cnt);

    --2. 분기처리
    if (v_cnt = 0) then
        -- 존재하지 않으면 insert
        insert into job_copy
        values(p_job_code, p_job_name);
    else
        -- 존재하면 update
        update job_copy
        set job_name = p_job_name
        where job_code = p_job_code;
    end if;
    
    --3. 트랙잭션 처리
    commit;
end;
/

--익명블럭에서 호출
begin
    proc_man_job_copy('J8', '수습사원');
end;
/

select * from job_copy;

delete from job_copy
where job_code = 'J8';
commit;


--------------------------------------------------------
--CUSOR
--------------------------------------------------------
--SQL의 처리결과 ResultSet을 가리키고 있는 포인터객체
--하나이상의 row에 순차적으로 접근가능

--1.암묵적 커서 : 모든 sql실행시 암묵적 커서가 만들어져 처리된다.
--2.명시적 커서: 변수로 선언 후 , open~fetch~clse 과정에 따라 행에 접근할 수 있다. 

declare
    v_emp emp_copy%rowtype;
    
    cursor my_cursor
    is
    select * from emp_copy 
    order by emp_id;
begin
    open my_cursor;
    loop
        fetch my_cursor into v_emp;
        exit when my_cursor%notfound;
        dbms_output.put_line('사번 : ' || v_emp.emp_id);
        dbms_output.put_line('사원명 : ' || v_emp.emp_name);
    end loop;
    close my_cursor;

end;
/


--파라미터가 있는 커서
declare
    v_emp emp_copy%rowtype;
    
    cursor my_cursor(p_dept_code emp_copy.dept_code%type)
    is
    select * 
    from emp_copy
    where dept_code = p_dept_code
    order by emp_id;
begin
    open my_cursor('&부서코드');
    loop
        fetch my_cursor into v_emp;
        exit when my_cursor%notfound;
        dbms_output.put_line('사번 : ' || v_emp.emp_id);
        dbms_output.put_line('사원명 : ' || v_emp.emp_name);
        dbms_output.put_line('부서코드 : ' || v_emp.dept_code);
        dbms_output.put_line(' ');
    end loop;
    close my_cursor;

end;
/


--for..in문을 통해 처리
--1. open~fetch~close 작업 자동
--2. 행변수는 자동으로 선언

declare
    cursor my_cursor(p_job_code emp_copy.job_code%type)
    is
    select emp_id, emp_name, job_code 
    from emp_copy
    where job_code = p_job_code;
begin
    for my_row in my_cursor('&직급코드') loop
        dbms_output.put_line(my_row.emp_id || ' : ' || my_row.emp_name);
    end loop;
end;
/

-------------------------------------------
-- TRIGGER
-------------------------------------------
--방아쇠, 연쇄반응
--특정이벤트(DDL, DML, LOGON)가 발생했을때,
--실행될 코드를 모아둔 데이터베이스 객체.

--종류
--1. DDL Trigger
--2. DML Trigger
--3. LOGON/LOGOFF Trigger

--게시판테이블의 게시물삭제 
-- 1. 삭제여부컬럼 : del_flag 'N' -> 'Y'
-- 2. 삭제테이블 : 삭제된 행 데이터를 삭제테이블에 insert 

/*
create or replace trigger 트리거명
    before | after                                  -- 원 DML문 실행 전 | 실행 후에 trigger 실행
    insert | update | delete on 테이블명
    [for each row]                                 -- 행 level 트리거, 생략하면 문장 level 트리거
begin
    --실행코드
end;
/

- 행레벨 트리거 : 원DML문(10행)이 처리되는 행마다 trigger실행(10번)
- 문장레벨 트리거 : 원DML문이 실행시 trigger 한번 실행

의사 pseudo 레코드 (행레벨트리거에서만 유효)
- :old 원DML문 실행전 데이터
- :new  원DML문 실행후 데이터

insert 
    :old null
    :new 추가된 데이터
    
update
    :old 변경전 데이터
    :new 변경후 데이터
    
delete
    :old 삭제전 데이터
    :new null

**트리거내부에서는 transaction처리 하지 않는다. 원DML문의 트랜잭션에 자동포함된다.

*/

create or replace trigger trig_emp_salary
    before
    insert or update of salary on emp_copy
    for each row
begin
    dbms_output.put_line('변경전 salary : ' || :old.salary);
    dbms_output.put_line('변경후 salary : ' || :new.salary);
    
    insert into emp_copy_salary_log (emp_id, before_salary, after_salary)
    values(:new.emp_id, :old.salary, :new.salary);
    --commit과 같은 트랜잭션 처리를 하지 않는다.
end;
/

--재컴파일 명령어
alter trigger trig_emp_salary compile;

update emp_copy 
set salary  = salary + 1000000
where dept_code = 'D5';

rollback; --trigger에서 실행된 dml문도 함께 rollback된다.

--PK 추가
alter table emp_copy
add constraints pk_emp_copy_emp_id primary key(emp_id);

--급여변경 로그테이블
create table emp_copy_salary_log (
    emp_id varchar2(3),
    before_salary number,
    after_salary number,
    log_date date default sysdate,
    constraint fk_emp_id foreign key(emp_id) references emp_copy(emp_id)
);

select * from emp_copy;
select * from emp_copy_salary_log;

--@실습문제
--emp_copy 에서 사원을 삭제할 경우, emp_copy_del 테이블로 데이터를 이전시키는 trigger를 생성하세요.
--quit_date에 현재날짜를 기록할 것.
create table emp_copy_del
as
select E.*
from emp_copy E
where 1 = 2;
