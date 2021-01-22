--=============================================================
--system 관리자 계정
--=============================================================
--한줄주석
/*
여러줄 주석
*/
show user;

--현재 등록된 사용자목록 조회
--sys 슈퍼관리자 : db생성/삭제 권한 있음.
--system 일반관리자: db생성/삭제 권한 없음.여러명 추가 가능

SELECT * from dba_users;

--sql문은 대소문자를 구분하지 않는다.
--사용자 계정의 비밀번호, 테이블 내의 데이터는 대소문자 구분한다.
select 
* from DBA_USERS;

--관리자는 일반사용자를 생성할 수 있다.
create user kh
identified by kh --비밀번호(대소문자 구분)
default tablespace users;--데이터가 저장 될 영역 -> system| users

--사용자 삭제
--drop users kh;

--접속권한 create session이 포함된 role(권한묶음)connect부여
--grant connect to kh
--테이블등 객체 생성 권한이 포함된 role resource 부여
--grant resource to kh;
--테이블 생성권한만 부여
--grant create table to kh;
--한번에 부여하기
grant connect, resource to kh;


