-----------------------------------------------------------------
--NON-EQUI JOIN
-----------------------------------------------------------------
--employee, sal_grade테이블을 조인
--employee테이블의 sal_level컬럼이 없다고 가정.
--employee.salary컬럼과 sal_grade.min_sal | sal_grade.max_sal을 비교해서 join

select * from employee;
select * from sal_grade;

--급여등급 조회 employee.salary between sal_grade.min_sal and sal_grade.max_sal

select emp_name, salary, SG.sal_level
from employee E
     join sal_grade SG
          on E.salary between SG.min_sal and SG.max_sal --non equi join
order by 3 desc,2;

--조인조건절에 따라 1행에 여러행이 연결된 결과를 얻을 수 있다.
select *
from employee E
join department D
on E.dept_code != D.dept_id
order by E.emp_id, D.dept_id; --여러행과 조인이 가능하다.

--======================================================
-- SET OPERATOR
--======================================================
--집합연산자. entity를 컬럼수가 동일하다는 조건하에 상하로 연결한 것.
--여러 개의 질의 결과(결과집합 result set)를 세로로 연결해서 하나의 가상 테이블을 리턴함.
--컬럼별 자료형이 상호호환 가능해야 한다. 문자형(char, varchar2)끼리 OK, 날짜형 + 문자열 ERROR
--컬럼명이 다른경우 컷번째 entity의 컬럼명을 결과집합에 반영
--order by 절은 마지막 enttity에서 딱 한번만 사용가능

--조건
--1. 컬럼수가 동일해야한다.
--2. 동일위치의 컬럼은 자료형이 상호호환 가능(char, varchar2 상호호환 가능)
--3. 컬럼명이 다른 경우 첫번째 컬럼명을 사용
--4. order by 절은 맨 마지막에 한 번만 사용가능

-- union 합집합
-- union all 합집합
-- intersect 교집합
-- minus 차집합

/*
A = {1, 3, 2, 5}
B = {2, 4, 6}

union      -> {1, 2, 3, 4, 5, 6} 중복제거, 첫번째 컬럼 기준 오름차순 정렬
union all -> {1, 3, 2, 5, 2, 4, 6}
intersect -> {2} 모든 컬럼이 일치하는 행만 리턴, 교집합!
minus -> A-B = {1, 3, 5} B-A = {4, 6}
*/

------------------------------------------------------
--UNION | UNION ALL
------------------------------------------------------

--A : 부서코드 D5인 사원의 사번, 사원명, 부서코드, 급여조회 결과집합 --6행
select emp_id, emp_name, dept_code, salary
from employee
where dept_code = 'D5';


--B : 급여가 300만원 이상인 사원조회 (사번, 사원명, 부서코드, 급여) --9행
select emp_id, emp_name, dept_code, salary
from employee
where salary >= 3000000;

--A UNION B --중복된 2행 빼고 13행 나옴 (심봉성, 대북혼 )
select emp_id, emp_name, dept_code, salary
from employee
where dept_code = 'D5'
--order by salary 마지막 entity에서만 사용 가능
union
select emp_id, emp_name, dept_code, salary
from employee
where salary >= 3000000;

--A UNION ALL B -- 중복된행까지 전부 나옴 
select emp_id, emp_name, dept_code, salary
from employee
where dept_code = 'D5'
union all
select emp_id, emp_name, dept_code, salary
from employee
where salary >= 3000000;

---------------------------------------------------------
--intersect | minus
---------------------------------------------------------
--A intersect B (교집합)
select emp_id 사원, emp_name 사원명, dept_code 부서코드, salary 급여
from employee
where dept_code = 'D5'
intersect
select emp_id, emp_name, dept_code, salary
from employee
where salary >= 3000000
order by 4;

--A minus B
select emp_id 사원, emp_name 사원명, dept_code 부서코드, salary 급여
from employee
where dept_code = 'D5'
minus
select emp_id, emp_name, dept_code, salary
from employee
where salary >= 3000000
order by 4;

--B minus A
select emp_id, emp_name, dept_code, salary
from employee
where salary >= 3000000
minus
select emp_id 사원, emp_name 사원명, dept_code 부서코드, salary 급여
from employee
where dept_code = 'D5'

--======================================================
-- SUB-QUERY
--======================================================
--하나의 sql문(main-query) 안에 종속된 또다른 sql문(sub-query)을 가리킨다.
--main-query에 종속적인 관계를 가지고 있다.
--존재하지 않는 값, 조건에 근거한 검색등을 실행할 때.

--1. 반드시 소괄호로 묶어서 처리할 것.
--2. 연산자 오른쪽에 작성할 것. where a = ()
--3. sub-query내에는 order by 문법이 지원 안됨.

-- 노옹철 직원의 관리자 이름을 조회

select * from employee;

select E1.emp_id "사원 사번",
       E1.emp_name "사원 이름",
       E2.manager_id "매니저 아이디",
       E2.emp_name "매니저 이름"
from employee E1 
join employee E2
on E1.manager_id = E2.emp_id
where E1.emp_name = '노옹철';

--1. 노옹철 사원행의 manager_id조회
--2. emp_id가 조회한 manager_id와 동일한 행의 emp_name을 조회
select manager_id
from employee
where emp_name = '노옹철';

select emp_name
from employee
where emp_id = '201';
      
-- 서브쿼리
-- 노옹철 -> manager_id -> emp_id -> emp_name
select emp_name
from employee
where emp_id = (select manager_id
                         from employee
                        where emp_name = '노옹철');--괄호부분이 서브쿼리

select manager_id
from employee
where emp_name = '노옹철';

               
-- 유형
--리턴값의 개수에 따른 분류
--1. 단일행 단일컬럼 서브쿼리
--2. 다중행 단일컬럼 서브쿼리
--3. 다중열 (단일행/다중행) 서브쿼리

--4. 상(호연)관 서브쿼리
--5. scala 스칼라(단일값) 서브쿼리

--6. inline-view 서브쿼리




--------------------------------------------------------
-- 단일행 단일컬럼 sub-query
--------------------------------------------------------
-- 서브쿼리 조회결과가 1행1열인 경우

--(전체평균급여)보다 많은 급여를 받는 사원 조회
select emp_name, salary, (select trunc(avg(salary))
                 from employee)--셀렉트절에 써도 가능 
from employee
where salary >= (select trunc(avg(salary))
                 from employee);
                 
--윤은해 사원과 같은 급여를 받는 사원조회(사번, 이름, 급여)
--1. 윤은해 사원급여 a
--2. 급여가 a와 동일한 사원조회 main

select emp_id 사번, emp_name 이름, salary 급여
from employee
where salary = (select salary
        from employee
        where emp_name = '윤은해')
       and emp_name != '윤은해';
       
--D1, D2 부서원 중에 D5부서의 평균급여보다 많은 급여를 받는 사원 조회(부서코드, 사번, 사원명, 급여)
select dept_code 부서코드, emp_id 사번, emp_name 이름, salary 급여    
from employee
where dept_code in ('D1','D2') and salary >=( select trunc(avg(salary))
                 from employee where dept_code in 'D5');

--직급이 대리인 사원 조회(사번, 사원명)

select * from job;
select * from employee;

--join

select E.emp_id 사번, E.emp_name 사원명
from employee E left join job J 
     on E.job_code = J.job_code
where J.job_name = '대리';

--sub-query
select emp_id 사번, emp_name 사원명
from employee
where job_code = (select job_code
        from job
        where job_name = '대리');
        
--------------------------------------------------------
-- 다중행 단일컬럼 sub-query
--------------------------------------------------------
--연산자  in | not in | any(some) | all | exists 와 함께 사용가능한 서브쿼리

--송종기, 하이유 사원이 속한 부서원 조회

select dept_code
from employee
where emp_name in ('송종기', '하이유');

select emp_name, dept_code
from employee
where dept_code in (select dept_code
                    from employee
                    where emp_name in ('송종기', '하이유'));
                    
 --not in
select emp_name, dept_code
from employee
where dept_code not in (select dept_code
                    from employee
                    where emp_name in ('송종기', '하이유'));
                    
-- 차태연, 전지연 사원의 급여등급(sal_level)과 같은 사원조회(사원명, 직급명, 급여등급 조회)
select emp_name 사원명,
            job_name 직급명,
            sal_level 급여등급
from employee E 
     join job  
     using(job_code)
where sal_level in (
                 select sal_level
                  from employee
                  where emp_name in ('차태연', ' 전지연')
                  )
                  and emp_name not in ('차태연', '전지연');



                    
--직급이 대표, 부사장이 아닌 사원 조회(사번,사원명, 직급코드)

select * from job;

select emp_id 사번, emp_name 사원명, dept_code 직급코드
from employee 
where job_code in (select job_code
                    from job
                    where job_code not in ('J1', 'J2'))
order by 1;

select emp_id 사번, emp_name 사원명, dept_code 직급코드
from employee E
where e.job_code not in (
                                    select job_code
                                    from job
                                    where job_name in ('대표', '부사장')--J1, J2
                                    );


--ASIA1 지역에 근무하는 사원 조회(사원명, 부서코드)
--location.local_name : ASIA1
--department.location_id --- location.local_code
--employee.dept_code --- department.dept_id

select * from location;
select * from job;
select * from employee;
select * from department;

select local_code
from location
where local_name = 'ASIA1';

select dept_id
from department
where location_id = 'L1';

select emp_name 사원명, dept_code 부서코드
from employee
where dept_code in (
                                select dept_id
                                from department
                                  where location_id = (
                                                                    select local_code
                                                                    from location
                                                                    where local_name = 'ASIA1'
                                                                    )
                                    );
                                          
----------------------------------------
--다중열 sub_query
----------------------------------------
--서브쿼리의 리턴된 컬럼이 여러개인 경우.

--단일행 다중행 동일한 문법으로 사용가능
                                          
--퇴사한 사원과 같은 부서, 같은 직급의 사원조회 (이름, 부서코드, 직급코드)

select emp_name 이름, dept_code 부서코드, job_code 직급코드
from employee
where quit_yn = 'Y';


select emp_name 이름, dept_code 부서코드, job_code 직급코드
from employee
where (dept_code, job_code) =(select dept_code, job_code
                                                from employee
                                                where quit_yn = 'Y');
                                                
                                                

--manager가 존재하지 않는 사원과 같은 부서코드, 직급코드를 가진 사원 조회
--in 연산자는 다중행 다중컬럼 처리 가능
select emp_name 이름, dept_code 부서코드, job_code 직급코드
from employee
where(nvl (dept_code, 'D0'), job_code) in(select nvl( dept_code, 'D0'), job_code
                                                from employee
                                                where manager_id is null);    --ORA-01427: single-row subquery returns more than one row  =을 in으로 바꿔주면 해결                                        
                                
--직급별 최소급여를 받는 사원 조회(사원명, 직급코드, 급여)

select job_code, min(salary)
from employee
group by job_code;

select emp_name 이름 , job_code 직급코드, salary 급여
from employee
where (job_code, salary) in (select job_code, min(salary)
                             from employee
                             group by job_code)
order by 2;

--부서별로 최대급여를 받는 사원 조회(사원명, 부서코드, 급여)

select emp_name, nvl(dept_code, '인턴'), salary
from employee
where (nvl(dept_code, '인턴'), salary) in (select nvl(dept_code, '인턴'), max(salary)
                             from employee
                             group by dept_code)
order by 2;

-- 각 부서별 최대급여와 최소급여를 받는 사원을 조회(사원명, 부서코드, 부서명, 급여)
select E.emp_name 사원명,
       nvl(dept_code, '인턴') 부서코드,
       nvl(D.dept_title, '인턴') 부서명,
       E.salary 급여
from employee E left join department D
     on E.dept_code = D.dept_id
where (nvl(dept_code, '인턴'),salary) in (select nvl(dept_code, '인턴'), max(salary)
                             from employee
                             group by dept_code)
      or (nvl(dept_code, '인턴'),salary) in (select nvl(dept_code, '인턴'), min(salary)
                            from employee
                            group by dept_code)
order by 2;



--------------------------------------------------------
-- 상관 sub-query
--------------------------------------------------------
-- 상호연관 서브쿼리
-- main-query의 값을 sub-query에 전달하고, 서브쿼리 수행 후 그 결과를 다시 main-query에 리턴해서 처리하는 방식
-- 각행마다 비교값이 다른 경우(각행의 컬럼값이 sub-query에 필요한 경우) 유용하다.
-- main-query의 table별칭이 반드시 필요하다.

-- 일반 sub-query : 단독으로 사용
-- 상관 sub-query : main-query로부터 값을 전달받아 사용

-- 직급별 평균급여보다 많은 급여를 받는 사원 조회
--join으로 처리
select *
from employee E
    join(
            select job_code, avg(salary) avg
            from employee
            group by job_code
        ) EA
        using(job_code)
where E.salary > EA.avg
order by job_code; 

--상관서브쿼리로 처리
select emp_name, job_code, salary
from employee E--메인쿼리 테이블 별칭이 반드시 필요
where salary > (select avg(salary)
                from employee
                where job_code = E.job_code)
order by 2;

select job_code, trunc(avg(salary))
from employee
group by job_code;

-- 부서코드별 평균급여보다 적은 급여를 받는 사원 조회(인턴포함)
select emp_name 사원명, nvl(dept_code, '인턴') 부서코드, salary 급여
from employee E
where salary < (select avg(salary)
                from employee
                where nvl(dept_code, '인턴') = nvl(E.dept_code, '인턴'))
order by 2;
