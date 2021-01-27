--나이추출시 주의점
--현재년도 - 탄생년도 + 1 =>한국식나이
select emp_name,
            emp_no,
            substr(emp_no, 1, 2),
--            extract(year from to_date(substr(emp_no, 1, 2), 'yy')),
--            extract(year from sysdate) - extract(year from to_date(substr(emp_no, 1, 2), 'yy')) + 1
--            extract(year from to_date(substr(emp_no, 1, 2), 'rr')),
--            extract(year from sysdate) - extract(year from to_date(substr(emp_no, 1, 2), 'rr')) + 1
                 extract(year from sysdate) - 
                ( decode(substr(emp_no, 8, 1), '1', 1900, '2' , 1900, 2000) +   substr(emp_no, 1, 2)) + 1 age
from employee;

--yy는 현재년도2021 기준으로 현재세기(2000~2099)범위에서 추측한다.
--yy는 현재년도2021 기준으로 (1950~2049)범위에서 추측한다.

--======================================================
-- DQL2
--======================================================
--------------------------------------------------------
--group by 
--------------------------------------------------------
--지정컬럼기준으로 세부적인 그룹핑이 가능하다.  지정, 컬럼, 가공된 값을 기준으로 그룹핑 가능
--group by 구문 없이는 전체를 하나의 그룹으로 취급한다.
--group by 절에 명시한 컬럼만 select절에 사용가능하다.
select dept_code,
--         emp_name, ---ORA-00979: not a GROUP BY expression
          sum(salary)
from employee
group by dept_code; --일반컬럼, 가공컬럼 다 올수있다.

select emp_name, dept_code, salary
from employee;

--직급별 급여 평균
select job_code,
        trunc(avg(salary), 1)
from employee
group by job_code
order by job_code;

--부서코드별 사원수 조회
select nvl(dept_code, 'intern')부서코드,
        count(*)사원수 
from employee
group by dept_code
order by dept_code; --컬럼순서, 별칭

        
--부서별 급여의 평균
--null도 하나의 그룹으로 인정해서 처리
select dept_code, trunc(avg(salary))
from employee
group by dept_code;


--부서코드별 사원수,급여평균, 급여 합계 조회
select dept_code 부서코드,
        count(*)사원수,
        to_char( trunc(avg(salary), 1), 'fml9,999,999,999,0') 급여평균,
        to_char(sum(salary), 'fml9,999,999,999') 급여합계
from employee
group by dept_code
order by dept_code; 

--입사년도별 사원수를 조회
select extract(year from hire_date) 입사년,
        count(*) 사원수
from employee
group by extract(year from hire_date)
order by 입사년;

--성별 인원수 ,평균급여 조회
select decode(substr(emp_no, 8, 1),'1', '남', '3', '남', '여') 성별,
       count(*) 인원수,
        to_char( trunc(avg(salary), 1), 'fml9,999,999,999,0') 급여평균
from employee
group by decode(substr(emp_no, 8, 1),'1', '남', '3', '남', '여')
order by 성별;

--J1직급을 제외하고 입사년도별 인원수를 조회
select  extract(year from hire_date) 입사년도,
           count(*)사원수       
from employee
where dept_code <> 'J1' -- ^= != <>
group by extract(year from hire_date)
order by 입사년도;

--입사년도별 사원수를 조회
select extract(year from hire_date) 입사년,
        count(*) 사원수
from employee
group by extract(year from hire_date)
order by 입사년;

--두개이상의 컬럼으로 grouping 가능
--null도 하나의 그룹으로 인식함.
select nvl(dept_code,'인턴') dept_code, --null값을 인턴으로 바꿔주는 nvl함수 넣어주면 null이 인턴으로 바뀜
       job_code,
       count(*)
from employee
group by dept_code, job_code
order by 1, 2;

--부서별 성별 인원수를 조회
select nvl(dept_code,'인턴') dept_code,
       decode(substr(emp_no, 8, 1),'1', '남', '3', '남', '여') 성별,
       count(decode(substr(emp_no, 8, 1),'1','남','3','남', '여')) 인원
from employee
group by dept_code, 
         decode(substr(emp_no, 8, 1),'1','남','3','남', '여')
order by 1, 2;



--------------------------------------------------------
--having
-------------------------------------------------------
-- 그룹핑한 결과에 대해서 조건절을 제시 ( group by 없이 단독으로는 못씀!) 
--group by 이후 조건절

-- 부서별 급여평균이 3,000,000원 이상인 부서를 조회

select dept_code,
       trunc(avg(salary)) avg
from employee
group by dept_code
having avg(salary) >= 3000000
order by 1;

--group 함수는 where절에 쓸 수 없다.

--직급별 인원수가 3명 이상인 직급과 인원수를 조회
select job_code 직급명,
       count(job_code) 인원수
from employee
group by job_code
having count(job_code) >= 3
order by 1;

-- 관리하는 사원이 2명이상인 manager의 아이디와 관리하는 사원수 조회
select manager_id managerID, count(*) 사원수
from employee
group by manager_id
having count(*) >= 2 and manager_id is not null -- =having count(manager_id) >= 2
order by 1;

-- rollup | cube(col1, col2...)
--group by 절에 사용하는 함수
--그룹핑 결과에 대해 소계(합계)를 제공
-- rollup 지정 컬럼에 대해서 단방향 소계 제공
-- cube 지정 컬럼에 대해서 양방향 소계 제공
--지정컬럼이 하나인 경우, rollup/cube 의 결과는 같다.


--하나일때는 rollup이나 cube나 차이가 없다.
select dept_code,
count(*)
from employee
group by rollup(dept_code)-- =cube
order by 1;


-- grouping() 
--실제데이터 | 집계데이터 컬럼을 구분하는 함수
-- null값 처리 가능 : 실제데이터 0을 리턴, 집계데이터면 1

select decode(grouping(dept_code), 0, nvl(dept_code, '인턴'), 1, '합계') dept_code,
--           grouping(dept_code),
          count(*)
from employee
group by rollup(dept_code)-- =cube
order by 1;

--두개이상의 컬럼을 rollup|cube에 전달하는 경우

select decode(grouping(dept_code), 0, nvl(dept_code, '인턴'), '합계') dept_code,
       decode(grouping(job_code), 0, job_code, '소계') job_code,
       count(*)
from employee
group by rollup(dept_code, job_code)
order by 1, 2;

select decode(grouping(dept_code), 0, nvl(dept_code, 'INTERN'), '소계') dept_code,
            decode(grouping(job_code), 0, job_code,' 소계') job_code,
            count(*)
from employee
group by cube(dept_code, job_code)
order by 1, 2;

/*
select(5) 보여주세요
from(1) 어느 
where(2) 
group by(3)
having(4)
order by(6) 이런순서로 정렬해서

*/


--table(entity relation) relation 만들기
-- 두개 이상의 테이블의 레코드를 연결해서 가상테이블(relation)생성
--1. join : 특정컬럼 기준으로 행과 행을 연결한다. (가로방향 합치기)
--2. union : 컬럼과 컬럼을 연결한다. 열 + 열 (세로방향 합치기)

--======================================================
-- JOIN
--======================================================
--두개 이상의 테이블을 연결해서 하나의 가상테이블(relation)을 생성
--기준 컬럼을 가지고 행을 연결한다.

--송종기 사원의 부서는?

select dept_code
from employee 
where emp_name = '송종기';


select *
from department;

select dept_title
from department
where dept_id = 'D9';

--join

select D.dept_title
from employee E join department D --테이블 별칭 , as나 "" 안쓴다.
     on E.dept_code = D.dept_id
where E.emp_name = '송종기';

select * from employee;
select * from department;



-- 조인조건에 따른 구분
--1. Equi Join : 동등비교조건(=)에 의해 join (대부분의 join)
--2. Non-Equi Join : 동등비교가 아닌 join - between and, is null, is not null, in, not in, != 등 (가끔 사용)

-- 문법에 따른 구분
-- 1. ANSI 표준문법 : DBMS에 상관없이 사용할수 있는 표준 SQL문법( 모든 DBMS 공통문법)
-- 2. Vendor사 문법 : DBMS별로 지원하는 문법, ORACLE 전용 문법.  join키워드 없이 ,(콤마) 사용

--equip-join 종류
/*1. inner join 내부조인
   2. outer join 외부조인 : 합집합 left, right, full 
   3. cross join : 모든 경우의 수를 고려한 조인
   4. self join
   5. multiple join
*/
