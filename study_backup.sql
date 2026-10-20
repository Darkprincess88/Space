--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
-- Dumped by pg_dump version 16.1

-- Started on 2025-10-30 13:56:39

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 10 (class 2615 OID 16789)
-- Name: db_study_hub; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA db_study_hub;


ALTER SCHEMA db_study_hub OWNER TO postgres;

--
-- TOC entry 996 (class 1247 OID 17210)
-- Name: days_of_week; Type: TYPE; Schema: db_study_hub; Owner: postgres
--

CREATE TYPE db_study_hub.days_of_week AS ENUM (
    'понедельник',
    'вторник',
    'среда',
    'четверг',
    'пятница',
    'суббота',
    'воскресенье'
);


ALTER TYPE db_study_hub.days_of_week OWNER TO postgres;

--
-- TOC entry 993 (class 1247 OID 17194)
-- Name: kinship_degree; Type: TYPE; Schema: db_study_hub; Owner: postgres
--

CREATE TYPE db_study_hub.kinship_degree AS ENUM (
    'родитель',
    'родственник',
    'опекун',
    'другое'
);


ALTER TYPE db_study_hub.kinship_degree OWNER TO postgres;

--
-- TOC entry 304 (class 1255 OID 17794)
-- Name: hash_password_trigger(); Type: FUNCTION; Schema: db_study_hub; Owner: postgres
--

CREATE FUNCTION db_study_hub.hash_password_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Проверяем, есть ли поле password и оно не пустое
  IF NEW.password IS NOT NULL AND NEW.password <> '' THEN
    -- Хэшируем пароль с помощью crypt() и генерируем соль автоматически
    NEW.password := crypt(NEW.password, gen_salt('bf'));
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION db_study_hub.hash_password_trigger() OWNER TO postgres;

--
-- TOC entry 283 (class 1255 OID 17795)
-- Name: log_table_changes(); Type: FUNCTION; Schema: db_study_hub; Owner: postgres
--

CREATE FUNCTION db_study_hub.log_table_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_old JSONB;
  v_new JSONB;
BEGIN
  -- Получение данных для логирования
  IF TG_OP = 'DELETE' THEN
    v_old := to_jsonb(OLD);
    v_new := NULL;
  ELSE
    v_old := NULL;
    v_new := to_jsonb(NEW);
  END IF;

  -- Вставка логов
  INSERT INTO db_study_hub.change_logs (table_name, operation, old_data, new_data)
  VALUES (TG_TABLE_NAME, TG_OP, v_old, v_new);

  RETURN NULL; -- Триггер не влияет на операцию
END;
$$;


ALTER FUNCTION db_study_hub.log_table_changes() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 262 (class 1259 OID 17232)
-- Name: academic_plans; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.academic_plans (
    id_class character varying NOT NULL,
    id_subject character varying NOT NULL,
    id_quater character varying NOT NULL,
    total_number_of_hours integer NOT NULL,
    number_of_hours_in_a_week integer NOT NULL,
    program_description character varying,
    id integer NOT NULL
);


ALTER TABLE db_study_hub.academic_plans OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 17827)
-- Name: academic_plans_id_seq; Type: SEQUENCE; Schema: db_study_hub; Owner: postgres
--

CREATE SEQUENCE db_study_hub.academic_plans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE db_study_hub.academic_plans_id_seq OWNER TO postgres;

--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 277
-- Name: academic_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: db_study_hub; Owner: postgres
--

ALTER SEQUENCE db_study_hub.academic_plans_id_seq OWNED BY db_study_hub.academic_plans.id;


--
-- TOC entry 269 (class 1259 OID 17299)
-- Name: actual_lessons; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.actual_lessons (
    id_actual_lesson character varying NOT NULL,
    id_static_lesson character varying NOT NULL,
    lesson_date date NOT NULL,
    id_lesson_change character varying,
    lesson_completed boolean NOT NULL,
    lesson_topic character varying NOT NULL,
    id_homework character varying
);


ALTER TABLE db_study_hub.actual_lessons OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 17187)
-- Name: assessment_types; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.assessment_types (
    id_assessment_type character varying NOT NULL,
    assessment_type_description character varying,
    coefficient numeric(3,2) DEFAULT 1 NOT NULL
);


ALTER TABLE db_study_hub.assessment_types OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 17268)
-- Name: attendance_and_assessments; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.attendance_and_assessments (
    id_student character varying NOT NULL,
    id_actual_lesson character varying NOT NULL,
    attended boolean NOT NULL,
    grade integer[],
    id_assessment_type character varying NOT NULL,
    comment character varying,
    billing_grade_date date NOT NULL,
    id integer NOT NULL
);


ALTER TABLE db_study_hub.attendance_and_assessments OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 17837)
-- Name: attendance_and_assessments_id_seq; Type: SEQUENCE; Schema: db_study_hub; Owner: postgres
--

CREATE SEQUENCE db_study_hub.attendance_and_assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE db_study_hub.attendance_and_assessments_id_seq OWNER TO postgres;

--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 278
-- Name: attendance_and_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: db_study_hub; Owner: postgres
--

ALTER SEQUENCE db_study_hub.attendance_and_assessments_id_seq OWNED BY db_study_hub.attendance_and_assessments.id;


--
-- TOC entry 258 (class 1259 OID 17171)
-- Name: cabinets; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.cabinets (
    id_cabinet character varying NOT NULL,
    cabinet_number character varying NOT NULL,
    id_staff character varying NOT NULL
);


ALTER TABLE db_study_hub.cabinets OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 17818)
-- Name: change_logs; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.change_logs (
    log_id integer NOT NULL,
    table_name text NOT NULL,
    operation character varying(10) NOT NULL,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    user_name character varying DEFAULT CURRENT_USER,
    old_data jsonb,
    new_data jsonb
);


ALTER TABLE db_study_hub.change_logs OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 17155)
-- Name: classes; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.classes (
    id_class character varying NOT NULL,
    date_starting_school date NOT NULL,
    date_ending_school date NOT NULL,
    id_class_teacher character varying,
    class_letter character varying
);


ALTER TABLE db_study_hub.classes OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 17278)
-- Name: final_assessments; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.final_assessments (
    id_quater character varying NOT NULL,
    id_student character varying NOT NULL,
    id_subject character varying NOT NULL,
    grade character varying NOT NULL,
    billing_grade_date date NOT NULL,
    id integer NOT NULL
);


ALTER TABLE db_study_hub.final_assessments OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 17847)
-- Name: final_assessments_id_seq; Type: SEQUENCE; Schema: db_study_hub; Owner: postgres
--

CREATE SEQUENCE db_study_hub.final_assessments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE db_study_hub.final_assessments_id_seq OWNER TO postgres;

--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 279
-- Name: final_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: db_study_hub; Owner: postgres
--

ALTER SEQUENCE db_study_hub.final_assessments_id_seq OWNED BY db_study_hub.final_assessments.id;


--
-- TOC entry 266 (class 1259 OID 17261)
-- Name: homeworks; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.homeworks (
    id_homework character varying NOT NULL,
    text_homework character varying NOT NULL,
    lessons_number_before_deadline integer,
    link_to_additional_materials character varying
);


ALTER TABLE db_study_hub.homeworks OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 17108)
-- Name: legal_representatives; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.legal_representatives (
    id_representatives character varying NOT NULL,
    id_user character varying NOT NULL,
    surname_representative character varying NOT NULL,
    name_representative character varying NOT NULL,
    patronymic_representative character varying,
    passport_series character varying NOT NULL,
    passport_number character varying NOT NULL,
    phone_number character varying NOT NULL,
    email character varying NOT NULL,
    residence_address character varying NOT NULL,
    date_of_birth date NOT NULL,
    spare_contact character varying
);


ALTER TABLE db_study_hub.legal_representatives OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 17249)
-- Name: lesson_changes; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.lesson_changes (
    id_lesson_change character varying NOT NULL,
    id_teacher character varying NOT NULL,
    id_subject character varying NOT NULL,
    id_cabinet character varying NOT NULL,
    lesson_change_reason character varying
);


ALTER TABLE db_study_hub.lesson_changes OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 17237)
-- Name: lessons_schedule; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.lessons_schedule (
    id_number_lesson character varying NOT NULL,
    number_of_lesson integer NOT NULL,
    time_start_lesson time without time zone NOT NULL,
    time_end_lesson time without time zone NOT NULL,
    id integer NOT NULL
);


ALTER TABLE db_study_hub.lessons_schedule OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 17857)
-- Name: lessons_schedule_id_seq; Type: SEQUENCE; Schema: db_study_hub; Owner: postgres
--

CREATE SEQUENCE db_study_hub.lessons_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE db_study_hub.lessons_schedule_id_seq OWNER TO postgres;

--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 280
-- Name: lessons_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: db_study_hub; Owner: postgres
--

ALTER SEQUENCE db_study_hub.lessons_schedule_id_seq OWNED BY db_study_hub.lessons_schedule.id;


--
-- TOC entry 251 (class 1259 OID 16806)
-- Name: posts; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.posts (
    id_post character varying NOT NULL,
    name_post character varying NOT NULL,
    salary_post character varying
);


ALTER TABLE db_study_hub.posts OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 17225)
-- Name: quarters; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.quarters (
    id_quarter character varying NOT NULL,
    quater_number integer NOT NULL,
    quater_start_date date NOT NULL,
    quater_end_date date NOT NULL
);


ALTER TABLE db_study_hub.quarters OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 16799)
-- Name: roles; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.roles (
    id_role character varying NOT NULL,
    name_role character varying NOT NULL,
    description_role character varying
);


ALTER TABLE db_study_hub.roles OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 16813)
-- Name: staffs; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.staffs (
    id_staff character varying NOT NULL,
    id_user character varying NOT NULL,
    id_post character varying NOT NULL,
    surname_staff character varying NOT NULL,
    name_staff character varying NOT NULL,
    patronymic_staff character varying,
    passport_series character varying NOT NULL,
    passport_number character varying NOT NULL,
    phone_number character varying NOT NULL,
    email character varying NOT NULL,
    residence_address character varying NOT NULL,
    date_of_birth date,
    hiring_date date NOT NULL
);


ALTER TABLE db_study_hub.staffs OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 17242)
-- Name: static_schedule; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.static_schedule (
    id_static_lesson character varying NOT NULL,
    id_subject character varying NOT NULL,
    id_cabinet character varying NOT NULL,
    id_teacher character varying NOT NULL,
    id_quarter character varying NOT NULL,
    day_of_week db_study_hub.days_of_week NOT NULL,
    id_number_lesson character varying NOT NULL,
    id_class character varying NOT NULL
);


ALTER TABLE db_study_hub.static_schedule OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 17135)
-- Name: students; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.students (
    id_student character varying NOT NULL,
    id_class character varying NOT NULL,
    id_user character varying NOT NULL,
    surname_student character varying NOT NULL,
    name_student character varying NOT NULL,
    patronymic_student character varying,
    date_of_birth date NOT NULL,
    date_starting_school date NOT NULL,
    residence_address character varying NOT NULL,
    email character varying NOT NULL
);


ALTER TABLE db_study_hub.students OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 17128)
-- Name: students_representatives; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.students_representatives (
    id_student character varying NOT NULL,
    id_representative character varying NOT NULL,
    kinship_degree db_study_hub.kinship_degree NOT NULL,
    id integer NOT NULL
);


ALTER TABLE db_study_hub.students_representatives OWNER TO postgres;

--
-- TOC entry 282 (class 1259 OID 17879)
-- Name: students_representatives_id_seq; Type: SEQUENCE; Schema: db_study_hub; Owner: postgres
--

CREATE SEQUENCE db_study_hub.students_representatives_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE db_study_hub.students_representatives_id_seq OWNER TO postgres;

--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 282
-- Name: students_representatives_id_seq; Type: SEQUENCE OWNED BY; Schema: db_study_hub; Owner: postgres
--

ALTER SEQUENCE db_study_hub.students_representatives_id_seq OWNED BY db_study_hub.students_representatives.id;


--
-- TOC entry 257 (class 1259 OID 17162)
-- Name: subjects; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.subjects (
    id_subject character varying NOT NULL,
    subject_name character varying NOT NULL,
    subject_description character varying
);


ALTER TABLE db_study_hub.subjects OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 17180)
-- Name: teachers_subjects; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.teachers_subjects (
    id_teacher character varying NOT NULL,
    id_subject character varying NOT NULL,
    id integer NOT NULL
);


ALTER TABLE db_study_hub.teachers_subjects OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 17869)
-- Name: teachers_subjects_id_seq; Type: SEQUENCE; Schema: db_study_hub; Owner: postgres
--

CREATE SEQUENCE db_study_hub.teachers_subjects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE db_study_hub.teachers_subjects_id_seq OWNER TO postgres;

--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 281
-- Name: teachers_subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: db_study_hub; Owner: postgres
--

ALTER SEQUENCE db_study_hub.teachers_subjects_id_seq OWNED BY db_study_hub.teachers_subjects.id;


--
-- TOC entry 249 (class 1259 OID 16790)
-- Name: users; Type: TABLE; Schema: db_study_hub; Owner: postgres
--

CREATE TABLE db_study_hub.users (
    id_user character varying NOT NULL,
    login character varying NOT NULL,
    password character varying NOT NULL,
    id_role character varying NOT NULL,
    registration_date date NOT NULL
);


ALTER TABLE db_study_hub.users OWNER TO postgres;

--
-- TOC entry 4882 (class 2604 OID 17828)
-- Name: academic_plans id; Type: DEFAULT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.academic_plans ALTER COLUMN id SET DEFAULT nextval('db_study_hub.academic_plans_id_seq'::regclass);


--
-- TOC entry 4884 (class 2604 OID 17838)
-- Name: attendance_and_assessments id; Type: DEFAULT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.attendance_and_assessments ALTER COLUMN id SET DEFAULT nextval('db_study_hub.attendance_and_assessments_id_seq'::regclass);


--
-- TOC entry 4885 (class 2604 OID 17848)
-- Name: final_assessments id; Type: DEFAULT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.final_assessments ALTER COLUMN id SET DEFAULT nextval('db_study_hub.final_assessments_id_seq'::regclass);


--
-- TOC entry 4883 (class 2604 OID 17858)
-- Name: lessons_schedule id; Type: DEFAULT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.lessons_schedule ALTER COLUMN id SET DEFAULT nextval('db_study_hub.lessons_schedule_id_seq'::regclass);


--
-- TOC entry 4879 (class 2604 OID 17880)
-- Name: students_representatives id; Type: DEFAULT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.students_representatives ALTER COLUMN id SET DEFAULT nextval('db_study_hub.students_representatives_id_seq'::regclass);


--
-- TOC entry 4880 (class 2604 OID 17870)
-- Name: teachers_subjects id; Type: DEFAULT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.teachers_subjects ALTER COLUMN id SET DEFAULT nextval('db_study_hub.teachers_subjects_id_seq'::regclass);


--
-- TOC entry 5169 (class 0 OID 17232)
-- Dependencies: 262
-- Data for Name: academic_plans; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class1', 'sub1', 'q1', 20, 4, 'Алгебра 10 класс', 1);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class1', 'sub2', 'q1', 15, 3, 'Русский 10 класс', 2);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class1', 'sub3', 'q1', 10, 2, 'Английский 10 класс', 3);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class1', 'sub4', 'q1', 10, 2, 'История 10 класс', 4);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class1', 'sub5', 'q1', 10, 2, 'Биология 10 класс', 5);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class1', 'sub1', 'q2', 20, 4, 'Алгебра 10 класс', 6);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class2', 'sub1', 'q1', 20, 4, 'Алгебра 10 класс', 7);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class2', 'sub2', 'q1', 15, 3, 'Русский 10 класс', 8);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class2', 'sub3', 'q1', 10, 2, 'Английский 10 класс', 9);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class3', 'sub1', 'q1', 15, 3, 'Математика 6 класс', 10);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class3', 'sub2', 'q1', 20, 4, 'Русский 6 класс', 11);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class3', 'sub3', 'q1', 10, 2, 'Английский 6 класс', 12);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class4', 'sub1', 'q1', 10, 2, 'Математика 1 класс', 13);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class4', 'sub2', 'q1', 15, 3, 'Русский 1 класс', 14);
INSERT INTO db_study_hub.academic_plans (id_class, id_subject, id_quater, total_number_of_hours, number_of_hours_in_a_week, program_description, id) VALUES ('class4', 'sub3', 'q1', 5, 1, 'Английский 1 класс', 15);


--
-- TOC entry 5176 (class 0 OID 17299)
-- Dependencies: 269
-- Data for Name: actual_lessons; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.actual_lessons (id_actual_lesson, id_static_lesson, lesson_date, id_lesson_change, lesson_completed, lesson_topic, id_homework) VALUES ('act1', 'stat1', '2025-10-01', NULL, true, 'Сложение дробей', 'hw1');
INSERT INTO db_study_hub.actual_lessons (id_actual_lesson, id_static_lesson, lesson_date, id_lesson_change, lesson_completed, lesson_topic, id_homework) VALUES ('act2', 'stat2', '2025-10-01', NULL, true, 'Грамматика: глаголы', 'hw2');
INSERT INTO db_study_hub.actual_lessons (id_actual_lesson, id_static_lesson, lesson_date, id_lesson_change, lesson_completed, lesson_topic, id_homework) VALUES ('act3', 'stat4', '2025-10-07', 'change1', true, 'Геометрия', NULL);


--
-- TOC entry 5167 (class 0 OID 17187)
-- Dependencies: 260
-- Data for Name: assessment_types; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.assessment_types (id_assessment_type, assessment_type_description, coefficient) VALUES ('at1', 'Контрольная работа', 2.00);
INSERT INTO db_study_hub.assessment_types (id_assessment_type, assessment_type_description, coefficient) VALUES ('at2', 'Домашняя работа', 1.00);
INSERT INTO db_study_hub.assessment_types (id_assessment_type, assessment_type_description, coefficient) VALUES ('at3', 'Устный ответ', 1.50);
INSERT INTO db_study_hub.assessment_types (id_assessment_type, assessment_type_description, coefficient) VALUES ('at4', 'Тест', 1.20);
INSERT INTO db_study_hub.assessment_types (id_assessment_type, assessment_type_description, coefficient) VALUES ('at5', 'Самостоятельная работа', 1.30);
INSERT INTO db_study_hub.assessment_types (id_assessment_type, assessment_type_description, coefficient) VALUES ('at6', 'Другое', 1.00);


--
-- TOC entry 5174 (class 0 OID 17268)
-- Dependencies: 267
-- Data for Name: attendance_and_assessments; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.attendance_and_assessments (id_student, id_actual_lesson, attended, grade, id_assessment_type, comment, billing_grade_date, id) VALUES ('stud40', 'act1', true, '{5}', 'at2', 'Хорошо', '2025-10-01', 1);
INSERT INTO db_study_hub.attendance_and_assessments (id_student, id_actual_lesson, attended, grade, id_assessment_type, comment, billing_grade_date, id) VALUES ('stud41', 'act1', true, '{4}', 'at2', 'Удовлетворительно', '2025-10-01', 2);


--
-- TOC entry 5165 (class 0 OID 17171)
-- Dependencies: 258
-- Data for Name: cabinets; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab1', '101', 'staff4');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab2', '102', 'staff5');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab3', '103', 'staff6');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab4', '104', 'staff7');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab5', '105', 'staff8');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab6', '201', 'staff9');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab7', '202', 'staff10');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab8', '203', 'staff11');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab9', '204', 'staff12');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab10', '205', 'staff13');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab11', '301', 'staff14');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab12', '302', 'staff15');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab13', '303', 'staff16');
INSERT INTO db_study_hub.cabinets (id_cabinet, cabinet_number, id_staff) VALUES ('cab14', '304', 'staff22');


--
-- TOC entry 5177 (class 0 OID 17818)
-- Dependencies: 276
-- Data for Name: change_logs; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--



--
-- TOC entry 5163 (class 0 OID 17155)
-- Dependencies: 256
-- Data for Name: classes; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.classes (id_class, date_starting_school, date_ending_school, id_class_teacher, class_letter) VALUES ('class1', '2016-09-01', '2027-05-31', 'staff4', 'А');
INSERT INTO db_study_hub.classes (id_class, date_starting_school, date_ending_school, id_class_teacher, class_letter) VALUES ('class2', '2016-09-01', '2027-05-31', 'staff5', 'Б');
INSERT INTO db_study_hub.classes (id_class, date_starting_school, date_ending_school, id_class_teacher, class_letter) VALUES ('class3', '2020-09-01', '2031-05-31', 'staff10', 'В');
INSERT INTO db_study_hub.classes (id_class, date_starting_school, date_ending_school, id_class_teacher, class_letter) VALUES ('class4', '2025-09-01', '2036-05-31', 'staff14', 'А');


--
-- TOC entry 5175 (class 0 OID 17278)
-- Dependencies: 268
-- Data for Name: final_assessments; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.final_assessments (id_quater, id_student, id_subject, grade, billing_grade_date, id) VALUES ('q1', 'stud40', 'sub1', '5', '2025-10-16', 1);
INSERT INTO db_study_hub.final_assessments (id_quater, id_student, id_subject, grade, billing_grade_date, id) VALUES ('q1', 'stud41', 'sub1', '4', '2025-10-16', 2);


--
-- TOC entry 5173 (class 0 OID 17261)
-- Dependencies: 266
-- Data for Name: homeworks; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.homeworks (id_homework, text_homework, lessons_number_before_deadline, link_to_additional_materials) VALUES ('hw1', 'Решить уравнения на стр. 45, №1-10', 2, 'https://mathbook.ru/page45.pdf');
INSERT INTO db_study_hub.homeworks (id_homework, text_homework, lessons_number_before_deadline, link_to_additional_materials) VALUES ('hw2', 'Прочитать текст и ответить на вопросы', 1, NULL);
INSERT INTO db_study_hub.homeworks (id_homework, text_homework, lessons_number_before_deadline, link_to_additional_materials) VALUES ('hw3', 'Нарисовать схему клетки', 3, 'https://biology.ru/cell.png');
INSERT INTO db_study_hub.homeworks (id_homework, text_homework, lessons_number_before_deadline, link_to_additional_materials) VALUES ('hw4', 'Выучить стихотворение Пушкина', 2, NULL);
INSERT INTO db_study_hub.homeworks (id_homework, text_homework, lessons_number_before_deadline, link_to_additional_materials) VALUES ('hw5', 'Подготовить доклад по истории', 4, 'https://history.ru/ww2.doc');


--
-- TOC entry 5160 (class 0 OID 17108)
-- Dependencies: 253
-- Data for Name: legal_representatives; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep1', 'user77', 'Попов', 'Иван', 'Петрович', '1001', '100001', '8 (900) 100-00-01', 'popov1980@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 12, кв. 34', '1980-01-01', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep2', 'user78', 'Соколова', 'Мария', 'Ивановна', '1002', '100002', '8 (900) 100-00-02', 'sokolova1985@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 34, кв. 12', '1985-02-02', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep3', 'user79', 'Лебедев', 'Сергей', 'Александрович', '1003', '100003', '8 (900) 100-00-03', 'lebedev1975@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 56, кв. 89', '1975-03-03', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep4', 'user80', 'Новикова', 'Ольга', 'Сергеевна', '1004', '100004', '8 (900) 100-00-04', 'novikova1990@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 8, кв. 15', '1990-04-04', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep5', 'user81', 'Морозов', 'Дмитрий', 'Викторович', '1005', '100005', '8 (900) 100-00-05', 'morozov1982@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 17, кв. 23', '1982-05-05', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep6', 'user82', 'Волкова', 'Анна', 'Павловна', '1006', '100006', '8 (900) 100-00-06', 'volkova1987@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 45, кв. 67', '1987-06-06', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep7', 'user83', 'Соловьев', 'Андрей', 'Николаевич', '1007', '100007', '8 (900) 100-00-07', 'soloviev1978@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 23, кв. 45', '1978-07-07', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep8', 'user84', 'Васильева', 'Елена', 'Дмитриевна', '1008', '100008', '8 (900) 100-00-08', 'vasilieva1993@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Союза Печатников, д. 15, кв. 28', '1993-08-08', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep9', 'user85', 'Петров', 'Виктор', 'Геннадьевич', '1009', '100009', '8 (900) 100-00-09', 'petrov1984@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 67, кв. 12', '1984-09-09', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep10', 'user86', 'Зайцева', 'Татьяна', 'Олеговна', '1010', '100010', '8 (900) 100-00-10', 'zaitseva1989@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 32, кв. 9', '1989-10-10', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep11', 'user87', 'Павлов', 'Максим', 'Анатольевич', '1011', '100011', '8 (900) 100-00-11', 'pavlov1979@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, Исаакиевская пл., д. 9, кв. 3', '1979-11-11', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep12', 'user88', 'Семенова', 'Юлия', 'Игоревна', '1012', '100012', '8 (900) 100-00-12', 'semenova1994@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Большая Морская, д. 18, кв. 7', '1994-12-12', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep13', 'user89', 'Богданов', 'Артем', 'Васильевич', '1013', '100013', '8 (900) 100-00-13', 'bogdanov1981@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Глинки, д. 5, кв. 14', '1981-01-13', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep14', 'user90', 'Федорова', 'Светлана', 'Юрьевна', '1014', '100014', '8 (900) 100-00-14', 'fedorova1986@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 33, кв. 22', '1986-02-14', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep15', 'user91', 'Михайлов', 'Надежда', 'Алексеевна', '1015', '100015', '8 (900) 100-00-15', 'mikhailov1976@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 44, кв. 18', '1976-03-15', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep16', 'user92', 'Беляева', 'Людмила', 'Николаевна', '1016', '100016', '8 (900) 100-00-16', 'belyaeva1991@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 89, кв. 31', '1991-04-16', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep17', 'user93', 'Тарасов', 'Галина', 'Борисовна', '1017', '100017', '8 (900) 100-00-17', 'tarasov1983@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 21, кв. 5', '1983-05-17', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep18', 'user94', 'Степанова', 'Ирина', 'Викторовна', '1018', '100018', '8 (900) 100-00-18', 'stepanova1988@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 12, кв. 8', '1988-06-18', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep19', 'user95', 'Кузьмин', 'Ольга', 'Александровна', '1019', '100019', '8 (900) 100-00-19', 'kuzmin1977@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 45, кв. 17', '1977-07-19', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep20', 'user96', 'Орлов', 'Елена', 'Дмитриевна', '1020', '100020', '8 (900) 100-00-20', 'orlov1992@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 8, кв. 11', '1992-08-20', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep21', 'user97', 'Андреева', 'Татьяна', 'Павловна', '1021', '100021', '8 (900) 100-00-21', 'andreeva1980@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 34, кв. 26', '1980-09-21', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep22', 'user98', 'Макаров', 'Юлия', 'Игоревна', '1022', '100022', '8 (900) 100-00-22', 'makarov1985@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 7, кв. 13', '1985-10-22', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep23', 'user99', 'Николаева', 'Светлана', 'Юрьевна', '1023', '100023', '8 (900) 100-00-23', 'nikolaeva1975@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 12, кв. 34', '1975-11-23', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep24', 'user100', 'Захаров', 'Надежда', 'Алексеевна', '1024', '100024', '8 (900) 100-00-24', 'zakharov1990@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 34, кв. 12', '1990-12-24', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep25', 'user101', 'Яковлева', 'Людмила', 'Николаевна', '1025', '100025', '8 (900) 100-00-25', 'yakoleva1982@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 56, кв. 89', '1982-01-25', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep26', 'user102', 'Романович', 'Галина', 'Борисовна', '1026', '100026', '8 (900) 100-00-26', 'romanovich1987@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 8, кв. 15', '1987-02-26', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep27', 'user103', 'Сергеева', 'Ирина', 'Викторовна', '1027', '100027', '8 (900) 100-00-27', 'sergeeva1978@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 17, кв. 23', '1978-03-27', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep28', 'user104', 'Алексеев', 'Ольга', 'Александровна', '1028', '100028', '8 (900) 100-00-28', 'alekseev1993@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 45, кв. 67', '1993-04-28', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep29', 'user105', 'Григорьев', 'Елена', 'Дмитриевна', '1029', '100029', '8 (900) 100-00-29', 'grigoriev1984@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 23, кв. 45', '1984-05-29', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep30', 'user106', 'Егорова', 'Татьяна', 'Павловна', '1030', '100030', '8 (900) 100-00-30', 'egorova1989@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Союза Печатников, д. 15, кв. 28', '1989-06-30', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep31', 'user107', 'Смирнов', 'Юлия', 'Игоревна', '1031', '100031', '8 (900) 100-00-31', 'smirnov1979@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 67, кв. 12', '1979-07-01', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep32', 'user108', 'Иванова', 'Светлана', 'Юрьевна', '1032', '100032', '8 (900) 100-00-32', 'ivanova1994@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 32, кв. 9', '1994-08-02', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep33', 'user109', 'Кузнецов', 'Надежда', 'Алексеевна', '1033', '100033', '8 (900) 100-00-33', 'kuznetsov1981@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, Исаакиевская пл., д. 9, кв. 3', '1981-09-03', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep34', 'user110', 'Попова', 'Людмила', 'Николаевна', '1034', '100034', '8 (900) 100-00-34', 'popova1986@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Большая Морская, д. 18, кв. 7', '1986-10-04', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep35', 'user111', 'Васильев', 'Галина', 'Борисовна', '1035', '100035', '8 (900) 100-00-35', 'vasiliev1976@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Глинки, д. 5, кв. 14', '1976-11-05', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep36', 'user112', 'Петрова', 'Ирина', 'Викторовна', '1036', '100036', '8 (900) 100-00-36', 'petrova1991@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 33, кв. 22', '1991-12-06', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep37', 'user113', 'Соколов', 'Ольга', 'Александровна', '1037', '100037', '8 (900) 100-00-37', 'sokolov1983@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 44, кв. 18', '1983-01-07', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep38', 'user114', 'Михайлова', 'Елена', 'Дмитриевна', '1038', '100038', '8 (900) 100-00-38', 'mikhailova1988@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 89, кв. 31', '1988-02-08', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep39', 'user115', 'Новиков', 'Татьяна', 'Павловна', '1039', '100039', '8 (900) 100-00-39', 'novikov1977@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 21, кв. 5', '1977-03-09', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep40', 'user116', 'Морозова', 'Юлия', 'Игоревна', '1040', '100040', '8 (900) 100-00-40', 'morozova1992@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 12, кв. 8', '1992-04-10', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep41', 'user117', 'Волков', 'Светлана', 'Юрьевна', '1041', '100041', '8 (900) 100-00-41', 'volkov1980@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 45, кв. 17', '1980-05-11', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep42', 'user118', 'Соловьева', 'Надежда', 'Алексеевна', '1042', '100042', '8 (900) 100-00-42', 'solovieva1985@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 8, кв. 11', '1985-06-12', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep43', 'user119', 'Васильев', 'Людмила', 'Николаевна', '1043', '100043', '8 (900) 100-00-43', 'vasiliev1975@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 34, кв. 26', '1975-07-13', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep44', 'user120', 'Петрова', 'Галина', 'Борисовна', '1044', '100044', '8 (900) 100-00-44', 'petrova1990@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 7, кв. 13', '1990-08-14', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep45', 'user121', 'Зайцев', 'Ирина', 'Викторовна', '1045', '100045', '8 (900) 100-00-45', 'zaitsev1982@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 12, кв. 34', '1982-09-15', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep46', 'user122', 'Павлова', 'Ольга', 'Александровна', '1046', '100046', '8 (900) 100-00-46', 'pavlova1987@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 34, кв. 12', '1987-10-16', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep47', 'user123', 'Семенов', 'Елена', 'Дмитриевна', '1047', '100047', '8 (900) 100-00-47', 'semenov1978@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 56, кв. 89', '1978-11-17', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep48', 'user124', 'Богданова', 'Татьяна', 'Павловна', '1048', '100048', '8 (900) 100-00-48', 'bogdanova1993@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 8, кв. 15', '1993-12-18', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep49', 'user125', 'Федоров', 'Юлия', 'Игоревна', '1049', '100049', '8 (900) 100-00-49', 'fedorov1984@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 17, кв. 23', '1984-01-19', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep50', 'user126', 'Михайлова', 'Светлана', 'Юрьевна', '1050', '100050', '8 (900) 100-00-50', 'mikhailova1989@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 45, кв. 67', '1989-02-20', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep51', 'user127', 'Беляев', 'Надежда', 'Алексеевна', '1051', '100051', '8 (900) 100-00-51', 'belyaev1979@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 23, кв. 45', '1979-03-21', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep52', 'user128', 'Тарасова', 'Людмила', 'Николаевна', '1052', '100052', '8 (900) 100-00-52', 'tarasova1994@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Союза Печатников, д. 15, кв. 28', '1994-04-22', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep53', 'user129', 'Степанов', 'Галина', 'Борисовна', '1053', '100053', '8 (900) 100-00-53', 'stepanov1981@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 67, кв. 12', '1981-05-23', NULL);
INSERT INTO db_study_hub.legal_representatives (id_representatives, id_user, surname_representative, name_representative, patronymic_representative, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, spare_contact) VALUES ('rep54', 'user130', 'Кузьмина', 'Ирина', 'Викторовна', '1054', '100054', '8 (900) 100-00-54', 'kuzmina1986@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 32, кв. 9', '1986-06-24', NULL);


--
-- TOC entry 5172 (class 0 OID 17249)
-- Dependencies: 265
-- Data for Name: lesson_changes; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.lesson_changes (id_lesson_change, id_teacher, id_subject, id_cabinet, lesson_change_reason) VALUES ('change1', 'staff4', 'sub1', 'cab1', 'Болезнь учителя');
INSERT INTO db_study_hub.lesson_changes (id_lesson_change, id_teacher, id_subject, id_cabinet, lesson_change_reason) VALUES ('change2', 'staff5', 'sub2', 'cab2', 'Ремонт кабинета');


--
-- TOC entry 5170 (class 0 OID 17237)
-- Dependencies: 263
-- Data for Name: lessons_schedule; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.lessons_schedule (id_number_lesson, number_of_lesson, time_start_lesson, time_end_lesson, id) VALUES ('lesson1', 1, '08:00:00', '08:45:00', 1);
INSERT INTO db_study_hub.lessons_schedule (id_number_lesson, number_of_lesson, time_start_lesson, time_end_lesson, id) VALUES ('lesson2', 2, '08:55:00', '09:40:00', 2);
INSERT INTO db_study_hub.lessons_schedule (id_number_lesson, number_of_lesson, time_start_lesson, time_end_lesson, id) VALUES ('lesson3', 3, '09:50:00', '10:35:00', 3);
INSERT INTO db_study_hub.lessons_schedule (id_number_lesson, number_of_lesson, time_start_lesson, time_end_lesson, id) VALUES ('lesson4', 4, '10:50:00', '11:35:00', 4);
INSERT INTO db_study_hub.lessons_schedule (id_number_lesson, number_of_lesson, time_start_lesson, time_end_lesson, id) VALUES ('lesson5', 5, '11:45:00', '12:30:00', 5);
INSERT INTO db_study_hub.lessons_schedule (id_number_lesson, number_of_lesson, time_start_lesson, time_end_lesson, id) VALUES ('lesson6', 6, '12:40:00', '13:25:00', 6);
INSERT INTO db_study_hub.lessons_schedule (id_number_lesson, number_of_lesson, time_start_lesson, time_end_lesson, id) VALUES ('lesson7', 7, '13:35:00', '14:20:00', 7);


--
-- TOC entry 5158 (class 0 OID 16806)
-- Dependencies: 251
-- Data for Name: posts; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.posts (id_post, name_post, salary_post) VALUES ('post1', 'Директор', '150000');
INSERT INTO db_study_hub.posts (id_post, name_post, salary_post) VALUES ('post2', 'Завуч', '90000');
INSERT INTO db_study_hub.posts (id_post, name_post, salary_post) VALUES ('post3', 'Методист', '55000');
INSERT INTO db_study_hub.posts (id_post, name_post, salary_post) VALUES ('post4', 'Учитель', '50000');
INSERT INTO db_study_hub.posts (id_post, name_post, salary_post) VALUES ('post5', 'Учитель начальных классов', '48000');
INSERT INTO db_study_hub.posts (id_post, name_post, salary_post) VALUES ('post6', 'Дворник', '25000');
INSERT INTO db_study_hub.posts (id_post, name_post, salary_post) VALUES ('post7', 'Уборщик', '25000');
INSERT INTO db_study_hub.posts (id_post, name_post, salary_post) VALUES ('post8', 'Охранник', '35000');
INSERT INTO db_study_hub.posts (id_post, name_post, salary_post) VALUES ('post9', 'Буфетчица', '32000');
INSERT INTO db_study_hub.posts (id_post, name_post, salary_post) VALUES ('post10', 'Медсестра', '42000');


--
-- TOC entry 5168 (class 0 OID 17225)
-- Dependencies: 261
-- Data for Name: quarters; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.quarters (id_quarter, quater_number, quater_start_date, quater_end_date) VALUES ('q1', 1, '2025-09-01', '2025-10-25');
INSERT INTO db_study_hub.quarters (id_quarter, quater_number, quater_start_date, quater_end_date) VALUES ('q2', 2, '2025-11-03', '2025-12-28');
INSERT INTO db_study_hub.quarters (id_quarter, quater_number, quater_start_date, quater_end_date) VALUES ('q3', 3, '2026-01-13', '2026-03-22');
INSERT INTO db_study_hub.quarters (id_quarter, quater_number, quater_start_date, quater_end_date) VALUES ('q4', 4, '2026-03-31', '2026-05-25');


--
-- TOC entry 5157 (class 0 OID 16799)
-- Dependencies: 250
-- Data for Name: roles; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.roles (id_role, name_role, description_role) VALUES ('role1', 'Администратор школы', 'Полный доступ к управлению базой данных.');
INSERT INTO db_study_hub.roles (id_role, name_role, description_role) VALUES ('role2', 'Учитель', 'Доступ к управлению своими классами, выставлению оценок, ведению журнала.');
INSERT INTO db_study_hub.roles (id_role, name_role, description_role) VALUES ('role3', 'Ученик', 'Доступ к просмотру своего расписания, оценок, домашних заданий.');
INSERT INTO db_study_hub.roles (id_role, name_role, description_role) VALUES ('role4', 'Родитель', 'Доступ к просмотру успеваемости своего ребенка.');


--
-- TOC entry 5159 (class 0 OID 16813)
-- Dependencies: 252
-- Data for Name: staffs; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff1', 'user1', 'post1', 'Иванов', 'Алексей', 'Сергеевич', '4512', '345678', '8 (904) 345-67-89', 'ivanov1975@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 12, кв. 34', '1975-03-15', '2018-09-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff2', 'user2', 'post2', 'Петрова', 'Мария', 'Владимировна', '3678', '123456', '8 (911) 234-56-78', 'petrova1980@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 34, кв. 12', '1980-07-20', '2019-01-15');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff3', 'user3', 'post3', 'Сидоров', 'Дмитрий', 'Игоревич', '2987', '654321', '8 (921) 456-78-90', 'sidorov1985@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 56, кв. 89', '1985-11-05', '2019-08-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff4', 'user4', 'post4', 'Кузнецова', 'Анна', 'Олеговна', '5123', '987654', '8 (904) 567-89-01', 'kuznetsova1990@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 8, кв. 15', '1990-02-10', '2020-09-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff5', 'user5', 'post4', 'Смирнов', 'Иван', 'Петрович', '6234', '876543', '8 (911) 678-90-12', 'smirnov1988@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 17, кв. 23', '1988-05-25', '2018-01-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff6', 'user6', 'post4', 'Федорова', 'Ольга', 'Александровна', '7345', '765432', '8 (921) 789-01-23', 'fedorova1982@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 45, кв. 67', '1982-09-30', '2017-03-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff7', 'user7', 'post4', 'Николаев', 'Сергей', 'Викторович', '8456', '654789', '8 (904) 890-12-34', 'nikolaev1979@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 23, кв. 45', '1979-12-15', '2016-06-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff8', 'user8', 'post4', 'Васильева', 'Елена', 'Дмитриевна', '9567', '543216', '8 (911) 901-23-45', 'vasileva1993@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Союза Печатников, д. 15, кв. 28', '1993-04-20', '2021-09-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff9', 'user9', 'post4', 'Алексеев', 'Андрей', 'Николаевич', '1678', '432125', '8 (921) 012-34-56', 'alekseev1987@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 67, кв. 12', '1987-08-05', '2019-07-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff10', 'user10', 'post4', 'Григорьева', 'Татьяна', 'Павловна', '2789', '321474', '8 (904) 123-45-67', 'grigorieva1984@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 32, кв. 9', '1984-01-10', '2020-01-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff11', 'user11', 'post4', 'Борисов', 'Максим', 'Анатольевич', '3890', '217543', '8 (911) 234-56-77', 'borisov1991@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, Исаакиевская пл., д. 9, кв. 3', '1991-06-25', '2020-09-15');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff12', 'user12', 'post4', 'Кириллова', 'Юлия', 'Игоревна', '4901', '165432', '8 (921) 345-67-89', 'kirillova1986@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Большая Морская, д. 18, кв. 7', '1986-10-30', '2018-11-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff13', 'user13', 'post5', 'Тихонов', 'Артем', 'Васильевич', '5012', '513226', '8 (904) 456-78-90', 'tikhonov1992@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Глинки, д. 5, кв. 14', '1992-03-05', '2021-12-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff14', 'user14', 'post5', 'Орлова', 'Светлана', 'Юрьевна', '6123', '432165', '8 (911) 567-89-01', 'orlova1989@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 33, кв. 22', '1989-07-20', '2017-02-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff15', 'user15', 'post5', 'Жуков', 'Владимир', 'Степанович', '7234', '321754', '8 (921) 678-90-12', 'zhukov1978@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 44, кв. 18', '1978-11-15', '2017-05-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff16', 'user16', 'post5', 'Воробьева', 'Надежда', 'Алексеевна', '8345', '216543', '8 (904) 789-01-23', 'vorobeva1983@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 89, кв. 31', '1983-02-10', '2021-08-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff17', 'user17', 'post6', 'Лебедев', 'Геннадий', 'Федорович', '9456', '162432', '8 (911) 890-12-34', 'lebedev1970@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 21, кв. 5', '1970-05-25', '2016-01-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff18', 'user18', 'post7', 'Комарова', 'Людмила', 'Николаевна', '1567', '653321', '8 (921) 901-23-45', 'komarova1972@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 12, кв. 8', '1972-09-30', '2015-04-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff19', 'user19', 'post8', 'Семенов', 'Виктор', 'Геннадьевич', '2678', '543116', '8 (904) 012-34-56', 'semenov1976@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 45, кв. 17', '1976-12-15', '2019-03-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff20', 'user20', 'post9', 'Павлова', 'Галина', 'Борисовна', '3789', '432162', '8 (911) 123-45-67', 'pavlova1981@mail.ru', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 8, кв. 11', '1981-04-20', '2020-06-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff21', 'user21', 'post10', 'Фролов', 'Олег', 'Денисович', '4890', '321654', '8 (921) 234-56-78', 'frolov1974@yandex.ru', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 34, кв. 26', '1974-08-05', '2018-10-01');
INSERT INTO db_study_hub.staffs (id_staff, id_user, id_post, surname_staff, name_staff, patronymic_staff, passport_series, passport_number, phone_number, email, residence_address, date_of_birth, hiring_date) VALUES ('staff22', 'user22', 'post4', 'Данилова', 'Ирина', 'Викторовна', '5901', '214243', '8 (904) 345-67-99', 'danilova1995@gmail.com', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 7, кв. 13', '1995-01-10', '2022-02-01');


--
-- TOC entry 5171 (class 0 OID 17242)
-- Dependencies: 264
-- Data for Name: static_schedule; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.static_schedule (id_static_lesson, id_subject, id_cabinet, id_teacher, id_quarter, day_of_week, id_number_lesson, id_class) VALUES ('stat1', 'sub1', 'cab11', 'staff14', 'q1', 'понедельник', 'lesson1', 'class4');
INSERT INTO db_study_hub.static_schedule (id_static_lesson, id_subject, id_cabinet, id_teacher, id_quarter, day_of_week, id_number_lesson, id_class) VALUES ('stat2', 'sub2', 'cab12', 'staff15', 'q1', 'понедельник', 'lesson2', 'class4');
INSERT INTO db_study_hub.static_schedule (id_static_lesson, id_subject, id_cabinet, id_teacher, id_quarter, day_of_week, id_number_lesson, id_class) VALUES ('stat3', 'sub3', 'cab13', 'staff16', 'q1', 'понедельник', 'lesson3', 'class4');
INSERT INTO db_study_hub.static_schedule (id_static_lesson, id_subject, id_cabinet, id_teacher, id_quarter, day_of_week, id_number_lesson, id_class) VALUES ('stat4', 'sub1', 'cab11', 'staff14', 'q1', 'вторник', 'lesson1', 'class4');


--
-- TOC entry 5162 (class 0 OID 17135)
-- Dependencies: 255
-- Data for Name: students; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud1', 'class1', 'user23', 'Попов', 'Александр', 'Иванович', '2009-05-12', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 12, кв. 34', 'popov2009@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud2', 'class1', 'user24', 'Соколова', 'Екатерина', 'Сергеевна', '2010-02-18', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 34, кв. 12', 'sokolova2010@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud3', 'class1', 'user25', 'Лебедев', 'Михаил', 'Алексеевич', '2009-08-22', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 56, кв. 89', 'lebedev2009@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud4', 'class1', 'user26', 'Новикова', 'Анна', 'Дмитриевна', '2010-11-07', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 8, кв. 15', 'novikova2010@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud5', 'class1', 'user27', 'Морозов', 'Дмитрий', 'Павлович', '2009-03-30', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 17, кв. 23', 'morozov2009@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud6', 'class1', 'user28', 'Волкова', 'Ольга', 'Викторовна', '2010-06-14', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 45, кв. 67', 'volkova2010@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud7', 'class1', 'user29', 'Соловьев', 'Сергей', 'Николаевич', '2009-09-19', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 23, кв. 45', 'soloviev2009@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud8', 'class1', 'user30', 'Васильева', 'Татьяна', 'Андреевна', '2010-01-25', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Союза Печатников, д. 15, кв. 28', 'vasilieva2010@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud9', 'class1', 'user31', 'Петров', 'Иван', 'Геннадьевич', '2009-04-03', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 67, кв. 12', 'petrov2009@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud10', 'class1', 'user32', 'Зайцева', 'Мария', 'Олеговна', '2010-07-09', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 32, кв. 9', 'zaitseva2010@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud11', 'class1', 'user33', 'Павлов', 'Алексей', 'Федорович', '2009-10-13', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Исаакиевская пл., д. 9, кв. 3', 'pavlov2009@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud12', 'class1', 'user34', 'Семенова', 'Юлия', 'Игоревна', '2010-12-28', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Большая Морская, д. 18, кв. 7', 'semenova2010@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud13', 'class2', 'user35', 'Богданов', 'Владимир', 'Степанович', '2009-01-16', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Глинки, д. 5, кв. 14', 'bogdanov2009@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud14', 'class2', 'user36', 'Федорова', 'Надежда', 'Алексеевна', '2010-04-21', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 33, кв. 22', 'fedorova2010@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud15', 'class2', 'user37', 'Михайлов', 'Геннадий', 'Федорович', '2009-07-26', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 44, кв. 18', 'mikhailov2009@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud16', 'class2', 'user38', 'Беляева', 'Людмила', 'Николаевна', '2010-10-01', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 89, кв. 31', 'belyaeva2010@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud17', 'class2', 'user39', 'Тарасов', 'Виктор', 'Геннадьевич', '2009-12-06', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 21, кв. 5', 'tarasov2009@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud18', 'class2', 'user40', 'Степанова', 'Галина', 'Борисовна', '2010-03-11', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 12, кв. 8', 'stepanova2010@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud19', 'class2', 'user41', 'Кузьмин', 'Олег', 'Денисович', '2009-05-16', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 45, кв. 17', 'kuzmin2009@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud20', 'class2', 'user42', 'Орлов', 'Ирина', 'Викторовна', '2010-08-21', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 8, кв. 11', 'orlov2010@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud21', 'class2', 'user43', 'Андреева', 'Светлана', 'Юрьевна', '2009-11-26', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 34, кв. 26', 'andreeva2009@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud22', 'class2', 'user44', 'Макаров', 'Артем', 'Васильевич', '2010-02-01', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 7, кв. 13', 'makarov2010@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud23', 'class2', 'user45', 'Николаева', 'Елена', 'Дмитриевна', '2009-04-06', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 12, кв. 34', 'nikolaeva2009@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud24', 'class2', 'user46', 'Захаров', 'Андрей', 'Николаевич', '2010-06-11', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 34, кв. 12', 'zakharov2010@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud25', 'class2', 'user47', 'Яковлева', 'Татьяна', 'Павловна', '2009-09-16', '2016-09-01', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 56, кв. 89', 'yakoleva2009@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud26', 'class3', 'user48', 'Романович', 'Максим', 'Анатольевич', '2014-01-21', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 8, кв. 15', 'romanovich2014@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud27', 'class3', 'user49', 'Сергеева', 'Юлия', 'Игоревна', '2015-04-26', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 17, кв. 23', 'sergeeva2015@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud28', 'class3', 'user50', 'Алексеев', 'Артем', 'Васильевич', '2014-07-01', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 45, кв. 67', 'alekseev2014@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud29', 'class3', 'user51', 'Григорьев', 'Светлана', 'Юрьевна', '2015-10-06', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 23, кв. 45', 'grigoriev2015@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud30', 'class3', 'user52', 'Егорова', 'Надежда', 'Алексеевна', '2014-12-11', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Союза Печатников, д. 15, кв. 28', 'egorova2014@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud31', 'class3', 'user53', 'Смирнов', 'Владимир', 'Степанович', '2015-03-16', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 67, кв. 12', 'smirnov2015@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud32', 'class3', 'user54', 'Иванова', 'Людмила', 'Николаевна', '2014-05-21', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 32, кв. 9', 'ivanova2014@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud33', 'class3', 'user55', 'Кузнецов', 'Галина', 'Борисовна', '2015-08-26', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Исаакиевская пл., д. 9, кв. 3', 'kuznetsov2015@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud34', 'class3', 'user56', 'Попова', 'Ирина', 'Викторовна', '2014-11-01', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Большая Морская, д. 18, кв. 7', 'popova2014@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud35', 'class3', 'user57', 'Васильев', 'Светлана', 'Юрьевна', '2015-01-06', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Глинки, д. 5, кв. 14', 'vasiliev2015@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud36', 'class3', 'user58', 'Петрова', 'Надежда', 'Алексеевна', '2014-03-11', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 33, кв. 22', 'petrova2014@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud37', 'class3', 'user59', 'Соколов', 'Владимир', 'Степанович', '2015-06-16', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 44, кв. 18', 'sokolov2015@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud38', 'class3', 'user60', 'Михайлова', 'Людмила', 'Николаевна', '2014-09-21', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 89, кв. 31', 'mikhailova2014@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud39', 'class3', 'user61', 'Новиков', 'Галина', 'Борисовна', '2015-12-26', '2020-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 21, кв. 5', 'novikov2015@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud40', 'class4', 'user62', 'Морозова', 'Ольга', 'Викторовна', '2018-02-01', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 12, кв. 8', 'morozova2018@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud41', 'class4', 'user63', 'Волков', 'Сергей', 'Николаевич', '2019-05-06', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 45, кв. 17', 'volkov2019@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud42', 'class4', 'user64', 'Соловьева', 'Татьяна', 'Андреевна', '2018-08-11', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 8, кв. 11', 'solovieva2018@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud43', 'class4', 'user65', 'Васильев', 'Иван', 'Геннадьевич', '2019-11-16', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 34, кв. 26', 'vasiliev2019@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud44', 'class4', 'user66', 'Петрова', 'Мария', 'Олеговна', '2018-01-21', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 7, кв. 13', 'petrova2018@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud45', 'class4', 'user67', 'Зайцев', 'Алексей', 'Федорович', '2019-04-26', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Гороховая, д. 12, кв. 34', 'zaitsev2019@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud46', 'class4', 'user68', 'Павлова', 'Юлия', 'Игоревна', '2018-07-01', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Вознесенский пр., д. 34, кв. 12', 'pavlova2018@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud47', 'class4', 'user69', 'Семенов', 'Владимир', 'Степанович', '2019-10-06', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, наб. Мойки, д. 56, кв. 89', 'semenov2019@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud48', 'class4', 'user70', 'Богданова', 'Надежда', 'Алексеевна', '2018-12-11', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Декабристов, д. 8, кв. 15', 'bogdanova2018@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud49', 'class4', 'user71', 'Федоров', 'Геннадий', 'Федорович', '2019-03-16', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, Английский пр., д. 17, кв. 23', 'fedorov2019@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud50', 'class4', 'user72', 'Михайлова', 'Людмила', 'Николаевна', '2018-05-21', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Писарева, д. 45, кв. 67', 'mikhailova2018@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud51', 'class4', 'user73', 'Беляев', 'Виктор', 'Геннадьевич', '2019-08-26', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, пр. Римского-Корсакова, д. 23, кв. 45', 'belyaev2019@yandex.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud52', 'class4', 'user74', 'Тарасова', 'Галина', 'Борисовна', '2018-11-01', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Союза Печатников, д. 15, кв. 28', 'tarasova2018@gmail.com');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud53', 'class4', 'user75', 'Степанов', 'Олег', 'Денисович', '2019-01-06', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, наб. Фонтанки, д. 67, кв. 12', 'stepanov2019@mail.ru');
INSERT INTO db_study_hub.students (id_student, id_class, id_user, surname_student, name_student, patronymic_student, date_of_birth, date_starting_school, residence_address, email) VALUES ('stud54', 'class4', 'user76', 'Кузьмина', 'Ирина', 'Викторовна', '2018-03-11', '2025-09-01', 'г. Санкт-Петербург, Адмиралтейский район, ул. Казанская, д. 32, кв. 9', 'kuzmina2018@yandex.ru');


--
-- TOC entry 5161 (class 0 OID 17128)
-- Dependencies: 254
-- Data for Name: students_representatives; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud1', 'rep1', 'родитель', 1);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud2', 'rep2', 'родитель', 2);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud3', 'rep3', 'родитель', 3);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud4', 'rep4', 'родитель', 4);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud5', 'rep5', 'родитель', 5);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud6', 'rep6', 'родитель', 6);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud7', 'rep7', 'родитель', 7);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud8', 'rep8', 'родитель', 8);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud9', 'rep9', 'родитель', 9);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud10', 'rep10', 'родитель', 10);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud11', 'rep11', 'родитель', 11);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud12', 'rep12', 'родитель', 12);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud13', 'rep13', 'родитель', 13);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud14', 'rep14', 'родитель', 14);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud15', 'rep15', 'родитель', 15);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud16', 'rep16', 'родитель', 16);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud17', 'rep17', 'родитель', 17);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud18', 'rep18', 'родитель', 18);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud19', 'rep19', 'родитель', 19);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud20', 'rep20', 'родитель', 20);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud21', 'rep21', 'родитель', 21);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud22', 'rep22', 'родитель', 22);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud23', 'rep23', 'родитель', 23);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud24', 'rep24', 'родитель', 24);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud25', 'rep25', 'родитель', 25);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud26', 'rep26', 'родитель', 26);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud27', 'rep27', 'родитель', 27);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud28', 'rep28', 'родитель', 28);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud29', 'rep29', 'родитель', 29);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud30', 'rep30', 'родитель', 30);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud31', 'rep31', 'родитель', 31);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud32', 'rep32', 'родитель', 32);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud33', 'rep33', 'родитель', 33);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud34', 'rep34', 'родитель', 34);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud35', 'rep35', 'родитель', 35);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud36', 'rep36', 'родитель', 36);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud37', 'rep37', 'родитель', 37);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud38', 'rep38', 'родитель', 38);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud39', 'rep39', 'родитель', 39);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud40', 'rep40', 'родитель', 40);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud41', 'rep41', 'родитель', 41);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud42', 'rep42', 'родитель', 42);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud43', 'rep43', 'родитель', 43);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud44', 'rep44', 'родитель', 44);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud45', 'rep45', 'родитель', 45);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud46', 'rep46', 'родитель', 46);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud47', 'rep47', 'родитель', 47);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud48', 'rep48', 'родитель', 48);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud49', 'rep49', 'родитель', 49);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud50', 'rep50', 'родитель', 50);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud51', 'rep51', 'родитель', 51);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud52', 'rep52', 'родитель', 52);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud53', 'rep53', 'родитель', 53);
INSERT INTO db_study_hub.students_representatives (id_student, id_representative, kinship_degree, id) VALUES ('stud54', 'rep54', 'родитель', 54);


--
-- TOC entry 5164 (class 0 OID 17162)
-- Dependencies: 257
-- Data for Name: subjects; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.subjects (id_subject, subject_name, subject_description) VALUES ('sub1', 'Математика', 'Изучение чисел, геометрии и алгебры.');
INSERT INTO db_study_hub.subjects (id_subject, subject_name, subject_description) VALUES ('sub2', 'Русский язык', 'Грамматика, орфография и литература.');
INSERT INTO db_study_hub.subjects (id_subject, subject_name, subject_description) VALUES ('sub3', 'Английский язык', 'Иностранный язык: грамматика и разговор.');
INSERT INTO db_study_hub.subjects (id_subject, subject_name, subject_description) VALUES ('sub4', 'История', 'История России и мира.');
INSERT INTO db_study_hub.subjects (id_subject, subject_name, subject_description) VALUES ('sub5', 'Биология', 'Изучение живой природы.');
INSERT INTO db_study_hub.subjects (id_subject, subject_name, subject_description) VALUES ('sub6', 'Физика', 'Законы движения и энергии.');
INSERT INTO db_study_hub.subjects (id_subject, subject_name, subject_description) VALUES ('sub7', 'Химия', 'Элементы и реакции.');
INSERT INTO db_study_hub.subjects (id_subject, subject_name, subject_description) VALUES ('sub8', 'Информатика', 'Компьютеры и программирование.');
INSERT INTO db_study_hub.subjects (id_subject, subject_name, subject_description) VALUES ('sub9', 'Физкультура', 'Спортивные занятия.');
INSERT INTO db_study_hub.subjects (id_subject, subject_name, subject_description) VALUES ('sub10', 'Литература', 'Анализ литературных произведений.');


--
-- TOC entry 5166 (class 0 OID 17180)
-- Dependencies: 259
-- Data for Name: teachers_subjects; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff4', 'sub1', 1);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff5', 'sub2', 2);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff6', 'sub3', 3);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff7', 'sub4', 4);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff8', 'sub5', 5);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff9', 'sub6', 6);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff10', 'sub7', 7);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff11', 'sub8', 8);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff12', 'sub9', 9);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff13', 'sub10', 10);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff14', 'sub1', 11);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff15', 'sub2', 12);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff16', 'sub3', 13);
INSERT INTO db_study_hub.teachers_subjects (id_teacher, id_subject, id) VALUES ('staff22', 'sub4', 14);


--
-- TOC entry 5156 (class 0 OID 16790)
-- Dependencies: 249
-- Data for Name: users; Type: TABLE DATA; Schema: db_study_hub; Owner: postgres
--

INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user1', 'ivanov1975', 'Ivanov123', 'role1', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user2', 'petrova1980', 'Petrova123', 'role1', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user3', 'sidorov1985', 'Sidorov123', 'role1', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user4', 'kuznetsova1990', 'Kuznetsova123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user5', 'smirnov1988', 'Smirnov123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user6', 'fedorova1982', 'Fedorova123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user7', 'nikolaev1979', 'Nikolaev123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user8', 'vasileva1993', 'Vasileva123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user9', 'alekseev1987', 'Alekseev123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user10', 'grigorieva1984', 'Grigorieva123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user11', 'borisov1991', 'Borisov123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user12', 'kirillova1986', 'Kirillova123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user13', 'tikhonov1992', 'Tikhonov123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user14', 'orlova1989', 'Orlova123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user15', 'zhukov1978', 'Zhukov123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user16', 'vorobeva1983', 'Vorobeva123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user17', 'lebedev1970', 'Lebedev123', 'role1', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user18', 'komarova1972', 'Komarova123', 'role1', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user19', 'semenov1976', 'Semenov123', 'role1', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user20', 'pavlova1981', 'Pavlova123', 'role1', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user21', 'frolov1974', 'Frolov123', 'role1', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user22', 'danilova1995', 'Danilova123', 'role2', '2025-01-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user23', 'popov2009', 'Popov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user24', 'sokolova2010', 'Sokolova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user25', 'lebedev2009', 'Lebedev123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user26', 'novikova2010', 'Novikova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user27', 'morozov2009', 'Morozov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user28', 'volkova2010', 'Volkova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user29', 'soloviev2009', 'Soloviev123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user30', 'vasilieva2010', 'Vasilieva123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user31', 'petrov2009', 'Petrov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user32', 'zaitseva2010', 'Zaitseva123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user33', 'pavlov2009', 'Pavlov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user34', 'semenova2010', 'Semenova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user35', 'bogdanov2009', 'Bogdanov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user36', 'fedorova2010', 'Fedorova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user37', 'mikhailov2009', 'Mikhailov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user38', 'belyaeva2010', 'Belyaeva123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user39', 'tarasov2009', 'Tarasov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user40', 'stepanova2010', 'Stepanova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user41', 'kuzmin2009', 'Kuzmin123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user42', 'orlov2010', 'Orlov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user43', 'andreeva2009', 'Andreeva123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user44', 'makarov2010', 'Makarov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user45', 'nikolaeva2009', 'Nikolaeva123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user46', 'zakharov2010', 'Zakharov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user47', 'yakoleva2009', 'Yakoleva123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user48', 'romanovich2014', 'Romanovich123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user49', 'sergeeva2015', 'Sergeeva123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user50', 'alekseev2014', 'Alekseev123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user51', 'grigoriev2015', 'Grigoriev123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user52', 'egorova2014', 'Egorova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user53', 'smirnov2015', 'Smirnov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user54', 'ivanova2014', 'Ivanova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user55', 'kuznetsov2015', 'Kuznetsov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user56', 'popova2014', 'Popova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user57', 'vasiliev2015', 'Vasiliev123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user58', 'petrova2014', 'Petrova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user59', 'sokolov2015', 'Sokolov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user60', 'mikhailova2014', 'Mikhailova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user61', 'novikov2015', 'Novikov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user62', 'morozova2018', 'Morozova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user63', 'volkov2019', 'Volkov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user64', 'solovieva2018', 'Solovieva123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user65', 'vasiliev2019', 'Vasiliev123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user66', 'petrova2018', 'Petrova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user67', 'zaitsev2019', 'Zaitsev123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user68', 'pavlova2018', 'Pavlova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user69', 'semenov2019', 'Semenov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user70', 'bogdanova2018', 'Bogdanova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user71', 'fedorov2019', 'Fedorov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user72', 'mikhailova2018', 'Mikhailova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user73', 'belyaev2019', 'Belyaev123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user74', 'tarasova2018', 'Tarasova123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user75', 'stepanov2019', 'Stepanov123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user76', 'kuzmina2018', 'Kuzmina123', 'role3', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user77', 'popov1980', 'Popov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user78', 'sokolova1985', 'Sokolova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user79', 'lebedev1975', 'Lebedev123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user80', 'novikova1990', 'Novikova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user81', 'morozov1982', 'Morozov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user82', 'volkova1987', 'Volkova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user83', 'soloviev1978', 'Soloviev123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user84', 'vasilieva1993', 'Vasilieva123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user85', 'petrov1984', 'Petrov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user86', 'zaitseva1989', 'Zaitseva123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user87', 'pavlov1979', 'Pavlov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user88', 'semenova1994', 'Semenova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user89', 'bogdanov1981', 'Bogdanov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user90', 'fedorova1986', 'Fedorova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user91', 'mikhailov1976', 'Mikhailov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user92', 'belyaeva1991', 'Belyaeva123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user93', 'tarasov1983', 'Tarasov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user94', 'stepanova1988', 'Stepanova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user95', 'kuzmin1977', 'Kuzmin123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user96', 'orlov1992', 'Orlov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user97', 'andreeva1980', 'Andreeva123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user98', 'makarov1985', 'Makarov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user99', 'nikolaeva1975', 'Nikolaeva123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user100', 'zakharov1990', 'Zakharov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user101', 'yakoleva1982', 'Yakoleva123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user102', 'romanovich1987', 'Romanovich123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user103', 'sergeeva1978', 'Sergeeva123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user104', 'alekseev1993', 'Alekseev123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user105', 'grigoriev1984', 'Grigoriev123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user106', 'egorova1989', 'Egorova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user107', 'smirnov1979', 'Smirnov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user108', 'ivanova1994', 'Ivanova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user109', 'kuznetsov1981', 'Kuznetsov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user110', 'popova1986', 'Popova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user111', 'vasiliev1976', 'Vasiliev123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user112', 'petrova1991', 'Petrova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user113', 'sokolov1983', 'Sokolov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user114', 'mikhailova1988', 'Mikhailova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user115', 'novikov1977', 'Novikov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user116', 'morozova1992', 'Morozova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user117', 'volkov1980', 'Volkov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user118', 'solovieva1985', 'Solovieva123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user119', 'vasiliev1975', 'Vasiliev123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user120', 'petrova1990', 'Petrova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user121', 'zaitsev1982', 'Zaitsev123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user122', 'pavlova1987', 'Pavlova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user123', 'semenov1978', 'Semenov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user124', 'bogdanova1993', 'Bogdanova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user125', 'fedorov1984', 'Fedorov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user126', 'mikhailova1989', 'Mikhailova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user127', 'belyaev1979', 'Belyaev123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user128', 'tarasova1994', 'Tarasova123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user129', 'stepanov1981', 'Stepanov123', 'role4', '2025-09-01');
INSERT INTO db_study_hub.users (id_user, login, password, id_role, registration_date) VALUES ('user130', 'kuzmina1986', 'Kuzmina123', 'role4', '2025-09-01');


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 277
-- Name: academic_plans_id_seq; Type: SEQUENCE SET; Schema: db_study_hub; Owner: postgres
--

SELECT pg_catalog.setval('db_study_hub.academic_plans_id_seq', 15, true);


--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 278
-- Name: attendance_and_assessments_id_seq; Type: SEQUENCE SET; Schema: db_study_hub; Owner: postgres
--

SELECT pg_catalog.setval('db_study_hub.attendance_and_assessments_id_seq', 2, true);


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 279
-- Name: final_assessments_id_seq; Type: SEQUENCE SET; Schema: db_study_hub; Owner: postgres
--

SELECT pg_catalog.setval('db_study_hub.final_assessments_id_seq', 2, true);


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 280
-- Name: lessons_schedule_id_seq; Type: SEQUENCE SET; Schema: db_study_hub; Owner: postgres
--

SELECT pg_catalog.setval('db_study_hub.lessons_schedule_id_seq', 7, true);


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 282
-- Name: students_representatives_id_seq; Type: SEQUENCE SET; Schema: db_study_hub; Owner: postgres
--

SELECT pg_catalog.setval('db_study_hub.students_representatives_id_seq', 54, true);


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 281
-- Name: teachers_subjects_id_seq; Type: SEQUENCE SET; Schema: db_study_hub; Owner: postgres
--

SELECT pg_catalog.setval('db_study_hub.teachers_subjects_id_seq', 14, true);


--
-- TOC entry 4939 (class 2606 OID 17830)
-- Name: academic_plans academic_plans_pkey; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.academic_plans
    ADD CONSTRAINT academic_plans_pkey PRIMARY KEY (id);


--
-- TOC entry 4955 (class 2606 OID 17305)
-- Name: actual_lessons actual_lessons_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.actual_lessons
    ADD CONSTRAINT actual_lessons_pk PRIMARY KEY (id_actual_lesson);


--
-- TOC entry 4935 (class 2606 OID 17284)
-- Name: assessment_types assessment_types_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.assessment_types
    ADD CONSTRAINT assessment_types_pk PRIMARY KEY (id_assessment_type);


--
-- TOC entry 4951 (class 2606 OID 17840)
-- Name: attendance_and_assessments attendance_and_assessments_pkey; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.attendance_and_assessments
    ADD CONSTRAINT attendance_and_assessments_pkey PRIMARY KEY (id);


--
-- TOC entry 4929 (class 2606 OID 17177)
-- Name: cabinets cabinets_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.cabinets
    ADD CONSTRAINT cabinets_pk PRIMARY KEY (id_cabinet);


--
-- TOC entry 4931 (class 2606 OID 17179)
-- Name: cabinets cabinets_unique; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.cabinets
    ADD CONSTRAINT cabinets_unique UNIQUE (cabinet_number);


--
-- TOC entry 4957 (class 2606 OID 17826)
-- Name: change_logs change_logs_pkey; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.change_logs
    ADD CONSTRAINT change_logs_pkey PRIMARY KEY (log_id);


--
-- TOC entry 4923 (class 2606 OID 17161)
-- Name: classes classes_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.classes
    ADD CONSTRAINT classes_pk PRIMARY KEY (id_class);


--
-- TOC entry 4953 (class 2606 OID 17850)
-- Name: final_assessments final_assessments_pkey; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.final_assessments
    ADD CONSTRAINT final_assessments_pkey PRIMARY KEY (id);


--
-- TOC entry 4949 (class 2606 OID 17267)
-- Name: homeworks homeworks_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.homeworks
    ADD CONSTRAINT homeworks_pk PRIMARY KEY (id_homework);


--
-- TOC entry 4905 (class 2606 OID 17114)
-- Name: legal_representatives legal_representatives_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.legal_representatives
    ADD CONSTRAINT legal_representatives_pk PRIMARY KEY (id_representatives);


--
-- TOC entry 4907 (class 2606 OID 17116)
-- Name: legal_representatives legal_representatives_unique; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.legal_representatives
    ADD CONSTRAINT legal_representatives_unique UNIQUE (id_user);


--
-- TOC entry 4909 (class 2606 OID 17118)
-- Name: legal_representatives legal_representatives_unique_1; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.legal_representatives
    ADD CONSTRAINT legal_representatives_unique_1 UNIQUE (passport_number);


--
-- TOC entry 4911 (class 2606 OID 17120)
-- Name: legal_representatives legal_representatives_unique_2; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.legal_representatives
    ADD CONSTRAINT legal_representatives_unique_2 UNIQUE (phone_number);


--
-- TOC entry 4913 (class 2606 OID 17122)
-- Name: legal_representatives legal_representatives_unique_3; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.legal_representatives
    ADD CONSTRAINT legal_representatives_unique_3 UNIQUE (email);


--
-- TOC entry 4947 (class 2606 OID 17255)
-- Name: lesson_changes lesson_changes_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.lesson_changes
    ADD CONSTRAINT lesson_changes_pk PRIMARY KEY (id_lesson_change);


--
-- TOC entry 4941 (class 2606 OID 17860)
-- Name: lessons_schedule lessons_schedule_pkey; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.lessons_schedule
    ADD CONSTRAINT lessons_schedule_pkey PRIMARY KEY (id);


--
-- TOC entry 4943 (class 2606 OID 17407)
-- Name: lessons_schedule lessons_schedule_unique; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.lessons_schedule
    ADD CONSTRAINT lessons_schedule_unique UNIQUE (id_number_lesson);


--
-- TOC entry 4917 (class 2606 OID 17141)
-- Name: students newtable_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.students
    ADD CONSTRAINT newtable_pk PRIMARY KEY (id_student);


--
-- TOC entry 4919 (class 2606 OID 17143)
-- Name: students newtable_unique; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.students
    ADD CONSTRAINT newtable_unique UNIQUE (id_user);


--
-- TOC entry 4921 (class 2606 OID 17145)
-- Name: students newtable_unique_1; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.students
    ADD CONSTRAINT newtable_unique_1 UNIQUE (email);


--
-- TOC entry 4895 (class 2606 OID 16812)
-- Name: posts posts_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.posts
    ADD CONSTRAINT posts_pk PRIMARY KEY (id_post);


--
-- TOC entry 4937 (class 2606 OID 17231)
-- Name: quarters quarters_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.quarters
    ADD CONSTRAINT quarters_pk PRIMARY KEY (id_quarter);


--
-- TOC entry 4893 (class 2606 OID 16805)
-- Name: roles roles_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.roles
    ADD CONSTRAINT roles_pk PRIMARY KEY (id_role);


--
-- TOC entry 4945 (class 2606 OID 17248)
-- Name: static_schedule schedule_template_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.static_schedule
    ADD CONSTRAINT schedule_template_pk PRIMARY KEY (id_static_lesson);


--
-- TOC entry 4897 (class 2606 OID 16819)
-- Name: staffs staffs_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.staffs
    ADD CONSTRAINT staffs_pk PRIMARY KEY (id_staff);


--
-- TOC entry 4899 (class 2606 OID 16821)
-- Name: staffs staffs_unique; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.staffs
    ADD CONSTRAINT staffs_unique UNIQUE (passport_number);


--
-- TOC entry 4901 (class 2606 OID 16823)
-- Name: staffs staffs_unique_1; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.staffs
    ADD CONSTRAINT staffs_unique_1 UNIQUE (phone_number);


--
-- TOC entry 4903 (class 2606 OID 16825)
-- Name: staffs staffs_unique_2; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.staffs
    ADD CONSTRAINT staffs_unique_2 UNIQUE (email);


--
-- TOC entry 4915 (class 2606 OID 17882)
-- Name: students_representatives students_representatives_pkey; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.students_representatives
    ADD CONSTRAINT students_representatives_pkey PRIMARY KEY (id);


--
-- TOC entry 4925 (class 2606 OID 17168)
-- Name: subjects subjects_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.subjects
    ADD CONSTRAINT subjects_pk PRIMARY KEY (id_subject);


--
-- TOC entry 4927 (class 2606 OID 17170)
-- Name: subjects subjects_unique; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.subjects
    ADD CONSTRAINT subjects_unique UNIQUE (subject_name);


--
-- TOC entry 4933 (class 2606 OID 17872)
-- Name: teachers_subjects teachers_subjects_pkey; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.teachers_subjects
    ADD CONSTRAINT teachers_subjects_pkey PRIMARY KEY (id);


--
-- TOC entry 4889 (class 2606 OID 16796)
-- Name: users users_pk; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.users
    ADD CONSTRAINT users_pk PRIMARY KEY (id_user);


--
-- TOC entry 4891 (class 2606 OID 16798)
-- Name: users users_unique; Type: CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.users
    ADD CONSTRAINT users_unique UNIQUE (login);


--
-- TOC entry 4991 (class 2620 OID 17796)
-- Name: users trg_hash_password; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_hash_password BEFORE INSERT OR UPDATE ON db_study_hub.users FOR EACH ROW EXECUTE FUNCTION db_study_hub.hash_password_trigger();


--
-- TOC entry 5005 (class 2620 OID 17797)
-- Name: academic_plans trg_log_changes_academic_plans; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_academic_plans AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.academic_plans FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5012 (class 2620 OID 17798)
-- Name: actual_lessons trg_log_changes_actual_lessons; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_actual_lessons AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.actual_lessons FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5003 (class 2620 OID 17799)
-- Name: assessment_types trg_log_changes_assessment_types; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_assessment_types AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.assessment_types FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5010 (class 2620 OID 17800)
-- Name: attendance_and_assessments trg_log_changes_attendance_and_assessments; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_attendance_and_assessments AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.attendance_and_assessments FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5001 (class 2620 OID 17801)
-- Name: cabinets trg_log_changes_cabinets; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_cabinets AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.cabinets FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 4999 (class 2620 OID 17802)
-- Name: classes trg_log_changes_classes; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_classes AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.classes FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5011 (class 2620 OID 17803)
-- Name: final_assessments trg_log_changes_final_assessments; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_final_assessments AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.final_assessments FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5009 (class 2620 OID 17804)
-- Name: homeworks trg_log_changes_homeworks; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_homeworks AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.homeworks FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 4996 (class 2620 OID 17805)
-- Name: legal_representatives trg_log_changes_legal_representatives; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_legal_representatives AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.legal_representatives FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5008 (class 2620 OID 17806)
-- Name: lesson_changes trg_log_changes_lesson_changes; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_lesson_changes AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.lesson_changes FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5006 (class 2620 OID 17807)
-- Name: lessons_schedule trg_log_changes_lessons_schedule; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_lessons_schedule AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.lessons_schedule FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 4994 (class 2620 OID 17808)
-- Name: posts trg_log_changes_posts; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_posts AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.posts FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5004 (class 2620 OID 17809)
-- Name: quarters trg_log_changes_quarters; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_quarters AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.quarters FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 4993 (class 2620 OID 17810)
-- Name: roles trg_log_changes_roles; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_roles AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.roles FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 4995 (class 2620 OID 17811)
-- Name: staffs trg_log_changes_staffs; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_staffs AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.staffs FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5007 (class 2620 OID 17812)
-- Name: static_schedule trg_log_changes_static_schedule; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_static_schedule AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.static_schedule FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 4998 (class 2620 OID 17813)
-- Name: students trg_log_changes_students; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_students AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.students FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 4997 (class 2620 OID 17814)
-- Name: students_representatives trg_log_changes_students_representatives; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_students_representatives AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.students_representatives FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5000 (class 2620 OID 17815)
-- Name: subjects trg_log_changes_subjects; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_subjects AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.subjects FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 5002 (class 2620 OID 17816)
-- Name: teachers_subjects trg_log_changes_teachers_subjects; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_teachers_subjects AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.teachers_subjects FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 4992 (class 2620 OID 17817)
-- Name: users trg_log_changes_users; Type: TRIGGER; Schema: db_study_hub; Owner: postgres
--

CREATE TRIGGER trg_log_changes_users AFTER INSERT OR DELETE OR UPDATE ON db_study_hub.users FOR EACH ROW EXECUTE FUNCTION db_study_hub.log_table_changes();


--
-- TOC entry 4970 (class 2606 OID 17478)
-- Name: academic_plans academic_plans_classes_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.academic_plans
    ADD CONSTRAINT academic_plans_classes_fk FOREIGN KEY (id_class) REFERENCES db_study_hub.classes(id_class);


--
-- TOC entry 4971 (class 2606 OID 17488)
-- Name: academic_plans academic_plans_quarters_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.academic_plans
    ADD CONSTRAINT academic_plans_quarters_fk FOREIGN KEY (id_quater) REFERENCES db_study_hub.quarters(id_quarter);


--
-- TOC entry 4972 (class 2606 OID 17483)
-- Name: academic_plans academic_plans_subjects_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.academic_plans
    ADD CONSTRAINT academic_plans_subjects_fk FOREIGN KEY (id_subject) REFERENCES db_study_hub.subjects(id_subject);


--
-- TOC entry 4988 (class 2606 OID 17317)
-- Name: actual_lessons actual_lessons_homeworks_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.actual_lessons
    ADD CONSTRAINT actual_lessons_homeworks_fk FOREIGN KEY (id_homework) REFERENCES db_study_hub.homeworks(id_homework);


--
-- TOC entry 4989 (class 2606 OID 17322)
-- Name: actual_lessons actual_lessons_lesson_changes_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.actual_lessons
    ADD CONSTRAINT actual_lessons_lesson_changes_fk FOREIGN KEY (id_lesson_change) REFERENCES db_study_hub.lesson_changes(id_lesson_change);


--
-- TOC entry 4990 (class 2606 OID 17312)
-- Name: actual_lessons actual_lessons_static_schedule_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.actual_lessons
    ADD CONSTRAINT actual_lessons_static_schedule_fk FOREIGN KEY (id_static_lesson) REFERENCES db_study_hub.static_schedule(id_static_lesson);


--
-- TOC entry 4982 (class 2606 OID 17307)
-- Name: attendance_and_assessments attendance_and_assessments_actual_lessons_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.attendance_and_assessments
    ADD CONSTRAINT attendance_and_assessments_actual_lessons_fk FOREIGN KEY (id_actual_lesson) REFERENCES db_study_hub.actual_lessons(id_actual_lesson);


--
-- TOC entry 4983 (class 2606 OID 17285)
-- Name: attendance_and_assessments attendance_and_assessments_assessment_types_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.attendance_and_assessments
    ADD CONSTRAINT attendance_and_assessments_assessment_types_fk FOREIGN KEY (id_assessment_type) REFERENCES db_study_hub.assessment_types(id_assessment_type);


--
-- TOC entry 4984 (class 2606 OID 17290)
-- Name: attendance_and_assessments attendance_and_assessments_students_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.attendance_and_assessments
    ADD CONSTRAINT attendance_and_assessments_students_fk FOREIGN KEY (id_student) REFERENCES db_study_hub.students(id_student);


--
-- TOC entry 4967 (class 2606 OID 17518)
-- Name: cabinets cabinets_staffs_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.cabinets
    ADD CONSTRAINT cabinets_staffs_fk FOREIGN KEY (id_staff) REFERENCES db_study_hub.staffs(id_staff);


--
-- TOC entry 4966 (class 2606 OID 17609)
-- Name: classes classes_staffs_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.classes
    ADD CONSTRAINT classes_staffs_fk FOREIGN KEY (id_class_teacher) REFERENCES db_study_hub.staffs(id_staff);


--
-- TOC entry 4985 (class 2606 OID 17327)
-- Name: final_assessments final_assessments_quarters_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.final_assessments
    ADD CONSTRAINT final_assessments_quarters_fk FOREIGN KEY (id_quater) REFERENCES db_study_hub.quarters(id_quarter);


--
-- TOC entry 4986 (class 2606 OID 17332)
-- Name: final_assessments final_assessments_students_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.final_assessments
    ADD CONSTRAINT final_assessments_students_fk FOREIGN KEY (id_student) REFERENCES db_study_hub.students(id_student);


--
-- TOC entry 4987 (class 2606 OID 17337)
-- Name: final_assessments final_assessments_subjects_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.final_assessments
    ADD CONSTRAINT final_assessments_subjects_fk FOREIGN KEY (id_subject) REFERENCES db_study_hub.subjects(id_subject);


--
-- TOC entry 4961 (class 2606 OID 17463)
-- Name: legal_representatives legal_representatives_users_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.legal_representatives
    ADD CONSTRAINT legal_representatives_users_fk FOREIGN KEY (id_user) REFERENCES db_study_hub.users(id_user);


--
-- TOC entry 4979 (class 2606 OID 17508)
-- Name: lesson_changes lesson_changes_cabinets_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.lesson_changes
    ADD CONSTRAINT lesson_changes_cabinets_fk FOREIGN KEY (id_cabinet) REFERENCES db_study_hub.cabinets(id_cabinet);


--
-- TOC entry 4980 (class 2606 OID 17498)
-- Name: lesson_changes lesson_changes_staffs_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.lesson_changes
    ADD CONSTRAINT lesson_changes_staffs_fk FOREIGN KEY (id_teacher) REFERENCES db_study_hub.staffs(id_staff);


--
-- TOC entry 4981 (class 2606 OID 17503)
-- Name: lesson_changes lesson_changes_subjects_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.lesson_changes
    ADD CONSTRAINT lesson_changes_subjects_fk FOREIGN KEY (id_subject) REFERENCES db_study_hub.subjects(id_subject);


--
-- TOC entry 4959 (class 2606 OID 17448)
-- Name: staffs staffs_posts_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.staffs
    ADD CONSTRAINT staffs_posts_fk FOREIGN KEY (id_post) REFERENCES db_study_hub.posts(id_post);


--
-- TOC entry 4960 (class 2606 OID 17453)
-- Name: staffs staffs_users_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.staffs
    ADD CONSTRAINT staffs_users_fk FOREIGN KEY (id_user) REFERENCES db_study_hub.users(id_user);


--
-- TOC entry 4973 (class 2606 OID 17418)
-- Name: static_schedule static_schedule_cabinets_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.static_schedule
    ADD CONSTRAINT static_schedule_cabinets_fk FOREIGN KEY (id_cabinet) REFERENCES db_study_hub.cabinets(id_cabinet);


--
-- TOC entry 4974 (class 2606 OID 17423)
-- Name: static_schedule static_schedule_classes_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.static_schedule
    ADD CONSTRAINT static_schedule_classes_fk FOREIGN KEY (id_class) REFERENCES db_study_hub.classes(id_class);


--
-- TOC entry 4975 (class 2606 OID 17408)
-- Name: static_schedule static_schedule_lessons_schedule_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.static_schedule
    ADD CONSTRAINT static_schedule_lessons_schedule_fk FOREIGN KEY (id_number_lesson) REFERENCES db_study_hub.lessons_schedule(id_number_lesson);


--
-- TOC entry 4976 (class 2606 OID 17433)
-- Name: static_schedule static_schedule_quarters_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.static_schedule
    ADD CONSTRAINT static_schedule_quarters_fk FOREIGN KEY (id_quarter) REFERENCES db_study_hub.quarters(id_quarter);


--
-- TOC entry 4977 (class 2606 OID 17428)
-- Name: static_schedule static_schedule_staffs_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.static_schedule
    ADD CONSTRAINT static_schedule_staffs_fk FOREIGN KEY (id_teacher) REFERENCES db_study_hub.staffs(id_staff);


--
-- TOC entry 4978 (class 2606 OID 17413)
-- Name: static_schedule static_schedule_subjects_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.static_schedule
    ADD CONSTRAINT static_schedule_subjects_fk FOREIGN KEY (id_subject) REFERENCES db_study_hub.subjects(id_subject);


--
-- TOC entry 4964 (class 2606 OID 17513)
-- Name: students students_classes_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.students
    ADD CONSTRAINT students_classes_fk FOREIGN KEY (id_class) REFERENCES db_study_hub.classes(id_class);


--
-- TOC entry 4962 (class 2606 OID 17443)
-- Name: students_representatives students_representatives_legal_representatives_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.students_representatives
    ADD CONSTRAINT students_representatives_legal_representatives_fk FOREIGN KEY (id_representative) REFERENCES db_study_hub.legal_representatives(id_representatives);


--
-- TOC entry 4963 (class 2606 OID 17438)
-- Name: students_representatives students_representatives_students_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.students_representatives
    ADD CONSTRAINT students_representatives_students_fk FOREIGN KEY (id_student) REFERENCES db_study_hub.students(id_student);


--
-- TOC entry 4965 (class 2606 OID 17458)
-- Name: students students_users_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.students
    ADD CONSTRAINT students_users_fk FOREIGN KEY (id_user) REFERENCES db_study_hub.users(id_user);


--
-- TOC entry 4968 (class 2606 OID 17468)
-- Name: teachers_subjects teachers_subjects_staffs_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.teachers_subjects
    ADD CONSTRAINT teachers_subjects_staffs_fk FOREIGN KEY (id_teacher) REFERENCES db_study_hub.staffs(id_staff);


--
-- TOC entry 4969 (class 2606 OID 17473)
-- Name: teachers_subjects teachers_subjects_subjects_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.teachers_subjects
    ADD CONSTRAINT teachers_subjects_subjects_fk FOREIGN KEY (id_subject) REFERENCES db_study_hub.subjects(id_subject);


--
-- TOC entry 4958 (class 2606 OID 17123)
-- Name: users users_roles_fk; Type: FK CONSTRAINT; Schema: db_study_hub; Owner: postgres
--

ALTER TABLE ONLY db_study_hub.users
    ADD CONSTRAINT users_roles_fk FOREIGN KEY (id_role) REFERENCES db_study_hub.roles(id_role);


-- Completed on 2025-10-30 13:56:43

--
-- PostgreSQL database dump complete
--

