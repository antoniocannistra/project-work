--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Postgres.app)
-- Dumped by pg_dump version 17.0

-- Started on 2025-04-30 10:36:46 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3796 (class 1262 OID 16390)
-- Name: trasporti; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE trasporti WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = icu LOCALE = 'en_US.UTF-8' ICU_LOCALE = 'en-US';


ALTER DATABASE trasporti OWNER TO postgres;

\connect trasporti

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 876 (class 1247 OID 16455)
-- Name: classe_treno; Type: TYPE; Schema: public; Owner: antoniocannistra
--

CREATE TYPE public.classe_treno AS ENUM (
    'PRIMA CLASSE',
    'SMART',
    'BUSINESS'
);


ALTER TYPE public.classe_treno OWNER TO antoniocannistra;

--
-- TOC entry 897 (class 1247 OID 24610)
-- Name: stato_prenotazione; Type: TYPE; Schema: public; Owner: antoniocannistra
--

CREATE TYPE public.stato_prenotazione AS ENUM (
    'IN_ATTESA',
    'CONFERMATA',
    'ANNULLATA',
    'COMPLETATA',
    'SCADUTA'
);


ALTER TYPE public.stato_prenotazione OWNER TO antoniocannistra;

--
-- TOC entry 238 (class 1255 OID 24722)
-- Name: aggiorna_prezzo_totale(); Type: FUNCTION; Schema: public; Owner: antoniocannistra
--

CREATE FUNCTION public.aggiorna_prezzo_totale() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE prenotazione
    SET prezzo_totale = (
        SELECT COALESCE(SUM(prezzo), 0)
        FROM biglietto
        WHERE id_prenotazione = NEW.id_prenotazione
          AND data_annullamento IS NULL
    )
    WHERE id_prenotazione = NEW.id_prenotazione;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.aggiorna_prezzo_totale() OWNER TO antoniocannistra;

--
-- TOC entry 237 (class 1255 OID 24720)
-- Name: aggiorna_stato_prenotazione_in_confermata(); Type: FUNCTION; Schema: public; Owner: antoniocannistra
--

CREATE FUNCTION public.aggiorna_stato_prenotazione_in_confermata() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Se lo stato è ancora "in attesa" e viene inserito un metodo di pagamento, cambia il valore in "confermata"
    IF NEW.stato = 'IN_ATTESA' AND NEW.id_metodo_pagamento IS NOT NULL THEN
        NEW.stato := 'CONFERMATA';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.aggiorna_stato_prenotazione_in_confermata() OWNER TO antoniocannistra;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16431)
-- Name: biglietto; Type: TABLE; Schema: public; Owner: antoniocannistra
--

CREATE TABLE public.biglietto (
    id_biglietto integer NOT NULL,
    data_emissione timestamp without time zone DEFAULT now() NOT NULL,
    data_scadenza timestamp without time zone,
    data_annullamento timestamp without time zone,
    data_validazione timestamp without time zone,
    id_prenotazione integer NOT NULL,
    id_tipologia integer NOT NULL,
    id_tratta integer NOT NULL,
    prezzo numeric(10,2) NOT NULL
);


ALTER TABLE public.biglietto OWNER TO antoniocannistra;

--
-- TOC entry 219 (class 1259 OID 16430)
-- Name: biglietto_id_biglietto_seq; Type: SEQUENCE; Schema: public; Owner: antoniocannistra
--

ALTER TABLE public.biglietto ALTER COLUMN id_biglietto ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.biglietto_id_biglietto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 229 (class 1259 OID 16490)
-- Name: effettua; Type: TABLE; Schema: public; Owner: antoniocannistra
--

CREATE TABLE public.effettua (
    id_effettua integer NOT NULL,
    partenza_prevista timestamp without time zone NOT NULL,
    partenza_effettiva timestamp without time zone,
    id_tratta integer NOT NULL,
    id_treno integer NOT NULL
);


ALTER TABLE public.effettua OWNER TO antoniocannistra;

--
-- TOC entry 228 (class 1259 OID 16489)
-- Name: effettua_id_effettua_seq; Type: SEQUENCE; Schema: public; Owner: antoniocannistra
--

ALTER TABLE public.effettua ALTER COLUMN id_effettua ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.effettua_id_effettua_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 236 (class 1259 OID 24680)
-- Name: fermate; Type: TABLE; Schema: public; Owner: antoniocannistra
--

CREATE TABLE public.fermate (
    id_fermata integer NOT NULL,
    id_tratta integer NOT NULL,
    id_stazione integer NOT NULL,
    tempo_attesa integer NOT NULL,
    partenza_prevista timestamp without time zone NOT NULL,
    partenza_effettiva timestamp without time zone,
    ordine integer NOT NULL
);


ALTER TABLE public.fermate OWNER TO antoniocannistra;

--
-- TOC entry 235 (class 1259 OID 24679)
-- Name: fermate_id_fermata_seq; Type: SEQUENCE; Schema: public; Owner: antoniocannistra
--

ALTER TABLE public.fermate ALTER COLUMN id_fermata ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fermate_id_fermata_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 232 (class 1259 OID 24604)
-- Name: metodo_pagamento; Type: TABLE; Schema: public; Owner: antoniocannistra
--

CREATE TABLE public.metodo_pagamento (
    id_metodo_pagamento integer NOT NULL,
    descrizione character varying(50) NOT NULL
);


ALTER TABLE public.metodo_pagamento OWNER TO antoniocannistra;

--
-- TOC entry 231 (class 1259 OID 24603)
-- Name: metodo_pagamento_id_metodo_pagamento_seq; Type: SEQUENCE; Schema: public; Owner: antoniocannistra
--

ALTER TABLE public.metodo_pagamento ALTER COLUMN id_metodo_pagamento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.metodo_pagamento_id_metodo_pagamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 218 (class 1259 OID 16410)
-- Name: passeggero; Type: TABLE; Schema: public; Owner: antoniocannistra
--

CREATE TABLE public.passeggero (
    id_passeggero integer NOT NULL,
    nome character varying(50) NOT NULL,
    cognome character varying(50) NOT NULL,
    email character varying(50) NOT NULL,
    cellulare character varying(20) NOT NULL,
    tessera character varying(11),
    cf character(16),
    p_iva character(11),
    via character varying(50),
    numero_civico character varying(4),
    cap character varying(10),
    provincia character varying(2),
    citta character varying(50),
    nazione character varying(30) DEFAULT 'ITALIA'::character varying
);


ALTER TABLE public.passeggero OWNER TO antoniocannistra;

--
-- TOC entry 217 (class 1259 OID 16409)
-- Name: passeggero_id_passeggero_seq; Type: SEQUENCE; Schema: public; Owner: antoniocannistra
--

ALTER TABLE public.passeggero ALTER COLUMN id_passeggero ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.passeggero_id_passeggero_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 234 (class 1259 OID 24622)
-- Name: prenotazione; Type: TABLE; Schema: public; Owner: antoniocannistra
--

CREATE TABLE public.prenotazione (
    id_prenotazione integer NOT NULL,
    stato public.stato_prenotazione DEFAULT 'IN_ATTESA'::public.stato_prenotazione NOT NULL,
    data_prenotazione timestamp without time zone DEFAULT now() NOT NULL,
    prezzo_totale numeric(10,2) DEFAULT 0.00 NOT NULL,
    id_passeggero integer NOT NULL,
    id_metodo_pagamento integer
);


ALTER TABLE public.prenotazione OWNER TO antoniocannistra;

--
-- TOC entry 233 (class 1259 OID 24621)
-- Name: prenotazione_id_prenotazione_seq; Type: SEQUENCE; Schema: public; Owner: antoniocannistra
--

ALTER TABLE public.prenotazione ALTER COLUMN id_prenotazione ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.prenotazione_id_prenotazione_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 16467)
-- Name: stazione; Type: TABLE; Schema: public; Owner: antoniocannistra
--

CREATE TABLE public.stazione (
    id_stazione integer NOT NULL,
    nome character varying(50) NOT NULL,
    citta character varying(50) NOT NULL,
    provincia character(2) NOT NULL,
    regione character varying(30) NOT NULL
);


ALTER TABLE public.stazione OWNER TO antoniocannistra;

--
-- TOC entry 224 (class 1259 OID 16466)
-- Name: stazione_id_stazione_seq; Type: SEQUENCE; Schema: public; Owner: antoniocannistra
--

ALTER TABLE public.stazione ALTER COLUMN id_stazione ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stazione_id_stazione_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 16443)
-- Name: tipologia_biglietto; Type: TABLE; Schema: public; Owner: antoniocannistra
--

CREATE TABLE public.tipologia_biglietto (
    id_tipologia integer NOT NULL,
    descrizione character varying(50) NOT NULL
);


ALTER TABLE public.tipologia_biglietto OWNER TO antoniocannistra;

--
-- TOC entry 221 (class 1259 OID 16442)
-- Name: tipologia_biglietto_id_tipologia_seq; Type: SEQUENCE; Schema: public; Owner: antoniocannistra
--

ALTER TABLE public.tipologia_biglietto ALTER COLUMN id_tipologia ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tipologia_biglietto_id_tipologia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 227 (class 1259 OID 16473)
-- Name: tratta; Type: TABLE; Schema: public; Owner: antoniocannistra
--

CREATE TABLE public.tratta (
    id_tratta integer NOT NULL,
    distanza numeric(6,2) NOT NULL,
    id_stazione_partenza integer NOT NULL,
    id_stazione_arrivo integer NOT NULL,
    durata_viaggio integer NOT NULL,
    cod_tratta character varying(15) NOT NULL
);


ALTER TABLE public.tratta OWNER TO antoniocannistra;

--
-- TOC entry 226 (class 1259 OID 16472)
-- Name: tratta_id_tratta_seq; Type: SEQUENCE; Schema: public; Owner: antoniocannistra
--

CREATE SEQUENCE public.tratta_id_tratta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tratta_id_tratta_seq OWNER TO antoniocannistra;

--
-- TOC entry 3797 (class 0 OID 0)
-- Dependencies: 226
-- Name: tratta_id_tratta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: antoniocannistra
--

ALTER SEQUENCE public.tratta_id_tratta_seq OWNED BY public.tratta.id_tratta;


--
-- TOC entry 223 (class 1259 OID 16461)
-- Name: treno; Type: TABLE; Schema: public; Owner: antoniocannistra
--

CREATE TABLE public.treno (
    matricola integer NOT NULL,
    classe public.classe_treno NOT NULL,
    numero_posti integer NOT NULL
);


ALTER TABLE public.treno OWNER TO antoniocannistra;

--
-- TOC entry 230 (class 1259 OID 24580)
-- Name: tratte_giornaliere; Type: MATERIALIZED VIEW; Schema: public; Owner: antoniocannistra
--

CREATE MATERIALIZED VIEW public.tratte_giornaliere AS
 SELECT s1.nome AS "Stazione di partenza",
    s2.nome AS "Stazione di arrivo",
    to_char(e.partenza_prevista, 'YYYY-MM-DD HH24:MI'::text) AS "data di partenza prevista",
    COALESCE(to_char(e.partenza_effettiva, 'YYYY-MM-DD HH24:MI'::text), 'Non ancora partito'::text) AS "data di partenza effettiva",
    tr.matricola AS "Matricola treno"
   FROM ((((public.effettua e
     JOIN public.tratta t ON ((e.id_tratta = t.id_tratta)))
     JOIN public.treno tr ON ((tr.matricola = e.id_treno)))
     JOIN public.stazione s1 ON ((s1.id_stazione = t.id_stazione_partenza)))
     JOIN public.stazione s2 ON ((s2.id_stazione = t.id_stazione_arrivo)))
  WHERE (date(e.partenza_prevista) = CURRENT_DATE)
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.tratte_giornaliere OWNER TO antoniocannistra;

--
-- TOC entry 3576 (class 2604 OID 16476)
-- Name: tratta id_tratta; Type: DEFAULT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.tratta ALTER COLUMN id_tratta SET DEFAULT nextval('public.tratta_id_tratta_seq'::regclass);


--
-- TOC entry 3774 (class 0 OID 16431)
-- Dependencies: 220
-- Data for Name: biglietto; Type: TABLE DATA; Schema: public; Owner: antoniocannistra
--

INSERT INTO public.biglietto OVERRIDING SYSTEM VALUE VALUES (22, '2025-04-22 13:46:44.209725', NULL, NULL, NULL, 1, 1, 1, 30.00);
INSERT INTO public.biglietto OVERRIDING SYSTEM VALUE VALUES (23, '2025-04-28 14:37:29.235573', NULL, NULL, '2025-04-28 17:00:50', 2, 1, 5, 6.00);
INSERT INTO public.biglietto OVERRIDING SYSTEM VALUE VALUES (25, '2025-04-28 14:38:30.018475', NULL, NULL, '2025-04-28 17:00:53', 2, 1, 7, 20.00);
INSERT INTO public.biglietto OVERRIDING SYSTEM VALUE VALUES (26, '2025-04-28 15:30:46.240773', NULL, NULL, NULL, 4, 1, 5, 6.00);
INSERT INTO public.biglietto OVERRIDING SYSTEM VALUE VALUES (27, '2025-04-29 13:58:07.442983', NULL, NULL, NULL, 7, 1, 5, 6.00);
INSERT INTO public.biglietto OVERRIDING SYSTEM VALUE VALUES (28, '2025-04-29 14:00:55.202007', NULL, NULL, NULL, 7, 1, 7, 20.00);


--
-- TOC entry 3783 (class 0 OID 16490)
-- Dependencies: 229
-- Data for Name: effettua; Type: TABLE DATA; Schema: public; Owner: antoniocannistra
--

INSERT INTO public.effettua OVERRIDING SYSTEM VALUE VALUES (3, '2025-03-19 23:59:04', '2025-03-20 23:58:38', 1, 100291);
INSERT INTO public.effettua OVERRIDING SYSTEM VALUE VALUES (5, '2025-03-26 18:00:00', NULL, 3, 100291);
INSERT INTO public.effettua OVERRIDING SYSTEM VALUE VALUES (6, '2025-03-26 18:15:00', NULL, 4, 100291);
INSERT INTO public.effettua OVERRIDING SYSTEM VALUE VALUES (7, '2025-04-22 16:27:18', '2025-04-22 16:30:22', 1, 100291);
INSERT INTO public.effettua OVERRIDING SYSTEM VALUE VALUES (9, '2025-04-29 17:33:01', NULL, 7, 100291);
INSERT INTO public.effettua OVERRIDING SYSTEM VALUE VALUES (8, '2025-04-28 17:32:51', '2025-04-28 18:39:20', 5, 100291);


--
-- TOC entry 3790 (class 0 OID 24680)
-- Dependencies: 236
-- Data for Name: fermate; Type: TABLE DATA; Schema: public; Owner: antoniocannistra
--

INSERT INTO public.fermate OVERRIDING SYSTEM VALUE VALUES (4, 1, 19, 10, '2025-04-22 23:52:13', NULL, 2);
INSERT INTO public.fermate OVERRIDING SYSTEM VALUE VALUES (3, 1, 18, 10, '2025-04-22 15:52:10', NULL, 1);
INSERT INTO public.fermate OVERRIDING SYSTEM VALUE VALUES (5, 4, 20, 5, '2025-04-24 15:10:00', NULL, 1);


--
-- TOC entry 3786 (class 0 OID 24604)
-- Dependencies: 232
-- Data for Name: metodo_pagamento; Type: TABLE DATA; Schema: public; Owner: antoniocannistra
--

INSERT INTO public.metodo_pagamento OVERRIDING SYSTEM VALUE VALUES (1, 'Paypal');
INSERT INTO public.metodo_pagamento OVERRIDING SYSTEM VALUE VALUES (3, 'Bonifico bancario');
INSERT INTO public.metodo_pagamento OVERRIDING SYSTEM VALUE VALUES (2, 'Carta di credito');


--
-- TOC entry 3772 (class 0 OID 16410)
-- Dependencies: 218
-- Data for Name: passeggero; Type: TABLE DATA; Schema: public; Owner: antoniocannistra
--

INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (1, 'Antonio', 'Cannistrà', 'prova@prova.it', '391234567', NULL, 'CNNNTN02T23F158D', NULL, 'Via Dei Mille', '36B', '98100', 'ME', 'Messina', 'ITALIA');
INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (4, 'Luca', 'Rossi', 'luca.rossi@email.com', '3331234567', 'TESS001', 'RSSLCU90A01H501X', NULL, 'Via Roma', '12', '00100', 'RM', 'Roma', 'ITALIA');
INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (5, 'Giulia', 'Bianchi', 'giulia.bianchi@email.com', '3347654321', 'TESS002', NULL, '01234567891', 'Via Milano', '7', '20100', 'MI', 'Milano', 'ITALIA');
INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (6, 'Marco', 'Verdi', 'marco.verdi@email.com', '3359876543', 'TESS003', 'VRDMRC92C12A794Y', NULL, 'Via Torino', '15', '10100', 'TO', 'Torino', 'ITALIA');
INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (7, 'Sara', 'Esposito', 'sara.esposito@email.com', '3361237890', 'TESS004', NULL, '09876543212', 'Via Napoli', '5', '80100', 'NA', 'Napoli', 'ITALIA');
INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (8, 'Francesco', 'Russo', 'francesco.russo@email.com', '3374567890', 'TESS005', 'RSSFNC91E22D325Q', NULL, 'Via Firenze', '20', '50100', 'FI', 'Firenze', 'ITALIA');
INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (9, 'Anna', 'Ferrari', 'anna.ferrari@email.com', '3383214567', 'TESS006', NULL, '03456789123', 'Via Venezia', '30', '30100', 'VE', 'Venezia', 'ITALIA');
INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (10, 'Davide', 'Gallo', 'davide.gallo@email.com', '3397894561', 'TESS007', 'GLLDVD93H11L219L', NULL, 'Via Palermo', '9', '90100', 'PA', 'Palermo', 'ITALIA');
INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (11, 'Marta', 'Romano', 'marta.romano@email.com', '3306547892', 'TESS008', NULL, '07654321891', 'Via Bari', '3', '70100', 'BA', 'Bari', 'ITALIA');
INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (12, 'Alessio', 'Conti', 'alessio.conti@email.com', '3317412589', 'TESS009', 'CNTLSS95P08F205M', NULL, 'Via Catania', '11', '95100', 'CT', 'Catania', 'ITALIA');
INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (13, 'Chiara', 'Greco', 'chiara.greco@email.com', '3329876543', 'TESS010', NULL, '05432109876', 'Via Genova', '22', '16100', 'GE', 'Genova', 'ITALIA');
INSERT INTO public.passeggero OVERRIDING SYSTEM VALUE VALUES (3, 'Mario', 'Bianchi', 'test@test.it', '344756543', 'TESS011', NULL, '01234567899', 'Viale Europa', '100', '98040', 'ME', 'Torregrotta', 'ITALIA');


--
-- TOC entry 3788 (class 0 OID 24622)
-- Dependencies: 234
-- Data for Name: prenotazione; Type: TABLE DATA; Schema: public; Owner: antoniocannistra
--

INSERT INTO public.prenotazione OVERRIDING SYSTEM VALUE VALUES (1, 'IN_ATTESA', '2025-04-22 09:52:27.982121', 30.00, 1, 1);
INSERT INTO public.prenotazione OVERRIDING SYSTEM VALUE VALUES (2, 'CONFERMATA', '2025-04-28 16:31:25', 26.00, 1, 1);
INSERT INTO public.prenotazione OVERRIDING SYSTEM VALUE VALUES (4, 'CONFERMATA', '2025-04-28 15:30:13.384903', 6.00, 3, 3);
INSERT INTO public.prenotazione OVERRIDING SYSTEM VALUE VALUES (7, 'CONFERMATA', '2025-04-29 13:57:16.727806', 26.00, 4, 1);


--
-- TOC entry 3779 (class 0 OID 16467)
-- Dependencies: 225
-- Data for Name: stazione; Type: TABLE DATA; Schema: public; Owner: antoniocannistra
--

INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (21, 'Milazzo Centrale', 'Milazzo', 'ME', 'Sicilia');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (2, 'Roma Termini', 'Roma', 'RM', 'Lazio');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (15, 'Trieste Centrale', 'Trieste', 'TS', 'Friuli Venezia Giulia');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (7, 'Bologna Centrale', 'Bologna', 'BO', 'Emilia-Romagna');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (13, 'Salerno', 'Salerno', 'SA', 'Campania');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (11, 'Pace Del Mela', 'Pace Del Mela', 'ME', 'Sicilia');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (10, 'Genova Piazza Principe', 'Genova', 'GE', 'Liguria');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (8, 'Bari Centrale', 'Bari', 'BA', 'Puglia');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (14, 'Reggio Calabria Centrale', 'Reggio Calabria', 'RC', 'Calabria');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (4, 'Firenze Santa Maria Novella', 'Firenze', 'FI', 'Toscana');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (3, 'Napoli Centrale', 'Napoli', 'NA', 'Campania');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (17, 'Torregrotta', 'Torregrotta', 'ME', 'Sicilia');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (16, 'Catania Centrale', 'Catania', 'CT', 'Sicilia');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (20, 'Villafranca Tirrena - Saponara', 'Villafranca Tirrena', 'ME', 'Sicilia');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (18, 'Napoli Afragola', 'Napoli', 'NA', 'Campania');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (1, 'Milano Centrale', 'Milano', 'MI', 'Lombardia');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (9, 'Verona Porta Nuova', 'Verona', 'VR', 'Veneto');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (5, 'Venezia Mestre', 'Venezia', 'VE', 'Veneto');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (6, 'Torino Porta Nuova', 'Torino', 'TO', 'Piemonte');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (19, 'Milano Rogoredo', 'Milano', 'MI', 'Lombardia');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (12, 'Messina Centrale', 'Messina', 'ME', 'Sicilia');
INSERT INTO public.stazione OVERRIDING SYSTEM VALUE VALUES (22, 'Villa S. Giovanni', 'Reggio Calabria', 'RC', 'Calabria');


--
-- TOC entry 3776 (class 0 OID 16443)
-- Dependencies: 222
-- Data for Name: tipologia_biglietto; Type: TABLE DATA; Schema: public; Owner: antoniocannistra
--

INSERT INTO public.tipologia_biglietto OVERRIDING SYSTEM VALUE VALUES (1, 'SINGOLO');
INSERT INTO public.tipologia_biglietto OVERRIDING SYSTEM VALUE VALUES (2, 'ABBONAMENTO SETTIMANALE');
INSERT INTO public.tipologia_biglietto OVERRIDING SYSTEM VALUE VALUES (3, 'ABBONAMENTO MENSILE');
INSERT INTO public.tipologia_biglietto OVERRIDING SYSTEM VALUE VALUES (4, 'ABBONAMENTO ANNUALE');


--
-- TOC entry 3781 (class 0 OID 16473)
-- Dependencies: 227
-- Data for Name: tratta; Type: TABLE DATA; Schema: public; Owner: antoniocannistra
--

INSERT INTO public.tratta VALUES (4, 15.00, 17, 12, 15, 'TOME15');
INSERT INTO public.tratta VALUES (1, 580.00, 3, 1, 180, 'NAMI180');
INSERT INTO public.tratta VALUES (3, 40.00, 11, 12, 28, 'PDMME28');
INSERT INTO public.tratta VALUES (2, 120.00, 11, 16, 60, 'PDMCT60');
INSERT INTO public.tratta VALUES (7, 25.00, 12, 22, 90, 'MEVSG90');
INSERT INTO public.tratta VALUES (5, 40.00, 21, 12, 35, 'MIME35');


--
-- TOC entry 3777 (class 0 OID 16461)
-- Dependencies: 223
-- Data for Name: treno; Type: TABLE DATA; Schema: public; Owner: antoniocannistra
--

INSERT INTO public.treno VALUES (100302, 'PRIMA CLASSE', 190);
INSERT INTO public.treno VALUES (100291, 'BUSINESS', 300);


--
-- TOC entry 3798 (class 0 OID 0)
-- Dependencies: 219
-- Name: biglietto_id_biglietto_seq; Type: SEQUENCE SET; Schema: public; Owner: antoniocannistra
--

SELECT pg_catalog.setval('public.biglietto_id_biglietto_seq', 28, true);


--
-- TOC entry 3799 (class 0 OID 0)
-- Dependencies: 228
-- Name: effettua_id_effettua_seq; Type: SEQUENCE SET; Schema: public; Owner: antoniocannistra
--

SELECT pg_catalog.setval('public.effettua_id_effettua_seq', 9, true);


--
-- TOC entry 3800 (class 0 OID 0)
-- Dependencies: 235
-- Name: fermate_id_fermata_seq; Type: SEQUENCE SET; Schema: public; Owner: antoniocannistra
--

SELECT pg_catalog.setval('public.fermate_id_fermata_seq', 5, true);


--
-- TOC entry 3801 (class 0 OID 0)
-- Dependencies: 231
-- Name: metodo_pagamento_id_metodo_pagamento_seq; Type: SEQUENCE SET; Schema: public; Owner: antoniocannistra
--

SELECT pg_catalog.setval('public.metodo_pagamento_id_metodo_pagamento_seq', 3, true);


--
-- TOC entry 3802 (class 0 OID 0)
-- Dependencies: 217
-- Name: passeggero_id_passeggero_seq; Type: SEQUENCE SET; Schema: public; Owner: antoniocannistra
--

SELECT pg_catalog.setval('public.passeggero_id_passeggero_seq', 13, true);


--
-- TOC entry 3803 (class 0 OID 0)
-- Dependencies: 233
-- Name: prenotazione_id_prenotazione_seq; Type: SEQUENCE SET; Schema: public; Owner: antoniocannistra
--

SELECT pg_catalog.setval('public.prenotazione_id_prenotazione_seq', 7, true);


--
-- TOC entry 3804 (class 0 OID 0)
-- Dependencies: 224
-- Name: stazione_id_stazione_seq; Type: SEQUENCE SET; Schema: public; Owner: antoniocannistra
--

SELECT pg_catalog.setval('public.stazione_id_stazione_seq', 22, true);


--
-- TOC entry 3805 (class 0 OID 0)
-- Dependencies: 221
-- Name: tipologia_biglietto_id_tipologia_seq; Type: SEQUENCE SET; Schema: public; Owner: antoniocannistra
--

SELECT pg_catalog.setval('public.tipologia_biglietto_id_tipologia_seq', 4, true);


--
-- TOC entry 3806 (class 0 OID 0)
-- Dependencies: 226
-- Name: tratta_id_tratta_seq; Type: SEQUENCE SET; Schema: public; Owner: antoniocannistra
--

SELECT pg_catalog.setval('public.tratta_id_tratta_seq', 7, true);


--
-- TOC entry 3590 (class 2606 OID 16436)
-- Name: biglietto biglietto_pkey; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.biglietto
    ADD CONSTRAINT biglietto_pkey PRIMARY KEY (id_biglietto);


--
-- TOC entry 3581 (class 2606 OID 16550)
-- Name: passeggero cf_unique; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.passeggero
    ADD CONSTRAINT cf_unique UNIQUE (cf);


--
-- TOC entry 3604 (class 2606 OID 16494)
-- Name: effettua effettua_pkey; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.effettua
    ADD CONSTRAINT effettua_pkey PRIMARY KEY (id_effettua);


--
-- TOC entry 3611 (class 2606 OID 24684)
-- Name: fermate fermate_pkey; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.fermate
    ADD CONSTRAINT fermate_pkey PRIMARY KEY (id_fermata);


--
-- TOC entry 3607 (class 2606 OID 24608)
-- Name: metodo_pagamento metodo_pagamento_pkey; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.metodo_pagamento
    ADD CONSTRAINT metodo_pagamento_pkey PRIMARY KEY (id_metodo_pagamento);


--
-- TOC entry 3584 (class 2606 OID 16414)
-- Name: passeggero passeggero_pkey; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.passeggero
    ADD CONSTRAINT passeggero_pkey PRIMARY KEY (id_passeggero);


--
-- TOC entry 3586 (class 2606 OID 16416)
-- Name: passeggero passeggero_tessera_key; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.passeggero
    ADD CONSTRAINT passeggero_tessera_key UNIQUE (tessera);


--
-- TOC entry 3609 (class 2606 OID 24628)
-- Name: prenotazione prenotazione_pkey; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.prenotazione
    ADD CONSTRAINT prenotazione_pkey PRIMARY KEY (id_prenotazione);


--
-- TOC entry 3597 (class 2606 OID 16471)
-- Name: stazione stazione_pkey; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.stazione
    ADD CONSTRAINT stazione_pkey PRIMARY KEY (id_stazione);


--
-- TOC entry 3592 (class 2606 OID 16447)
-- Name: tipologia_biglietto tipologia_biglietto_pkey; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.tipologia_biglietto
    ADD CONSTRAINT tipologia_biglietto_pkey PRIMARY KEY (id_tipologia);


--
-- TOC entry 3600 (class 2606 OID 16478)
-- Name: tratta tratta_pkey; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.tratta
    ADD CONSTRAINT tratta_pkey PRIMARY KEY (id_tratta);


--
-- TOC entry 3594 (class 2606 OID 16465)
-- Name: treno treno_pkey; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.treno
    ADD CONSTRAINT treno_pkey PRIMARY KEY (matricola);


--
-- TOC entry 3602 (class 2606 OID 24718)
-- Name: tratta unique_cod_tratta; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.tratta
    ADD CONSTRAINT unique_cod_tratta UNIQUE (cod_tratta);


--
-- TOC entry 3588 (class 2606 OID 24579)
-- Name: passeggero unique_piva; Type: CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.passeggero
    ADD CONSTRAINT unique_piva UNIQUE (p_iva);


--
-- TOC entry 3605 (class 1259 OID 24594)
-- Name: idx_effettua_partenza_prevista; Type: INDEX; Schema: public; Owner: antoniocannistra
--

CREATE INDEX idx_effettua_partenza_prevista ON public.effettua USING btree (partenza_prevista);


--
-- TOC entry 3582 (class 1259 OID 24592)
-- Name: idx_passeggero_nome_cognome; Type: INDEX; Schema: public; Owner: antoniocannistra
--

CREATE INDEX idx_passeggero_nome_cognome ON public.passeggero USING btree (nome, cognome);


--
-- TOC entry 3595 (class 1259 OID 24593)
-- Name: idx_stazione_nome; Type: INDEX; Schema: public; Owner: antoniocannistra
--

CREATE INDEX idx_stazione_nome ON public.stazione USING btree (nome);


--
-- TOC entry 3598 (class 1259 OID 24719)
-- Name: idx_tratta_cod_tratta; Type: INDEX; Schema: public; Owner: antoniocannistra
--

CREATE INDEX idx_tratta_cod_tratta ON public.tratta USING btree (cod_tratta);


--
-- TOC entry 3623 (class 2620 OID 24723)
-- Name: biglietto trigger_aggiorna_prezzo_totale; Type: TRIGGER; Schema: public; Owner: antoniocannistra
--

CREATE TRIGGER trigger_aggiorna_prezzo_totale AFTER INSERT OR DELETE OR UPDATE ON public.biglietto FOR EACH ROW EXECUTE FUNCTION public.aggiorna_prezzo_totale();


--
-- TOC entry 3624 (class 2620 OID 24721)
-- Name: prenotazione trigger_stato_confermata; Type: TRIGGER; Schema: public; Owner: antoniocannistra
--

CREATE TRIGGER trigger_stato_confermata BEFORE UPDATE ON public.prenotazione FOR EACH ROW EXECUTE FUNCTION public.aggiorna_stato_prenotazione_in_confermata();


--
-- TOC entry 3612 (class 2606 OID 24695)
-- Name: biglietto biglietto_tratta_fk; Type: FK CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.biglietto
    ADD CONSTRAINT biglietto_tratta_fk FOREIGN KEY (id_tratta) REFERENCES public.tratta(id_tratta);


--
-- TOC entry 3617 (class 2606 OID 16495)
-- Name: effettua effettua_id_tratta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.effettua
    ADD CONSTRAINT effettua_id_tratta_fkey FOREIGN KEY (id_tratta) REFERENCES public.tratta(id_tratta) ON DELETE CASCADE;


--
-- TOC entry 3618 (class 2606 OID 16500)
-- Name: effettua effettua_id_treno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.effettua
    ADD CONSTRAINT effettua_id_treno_fkey FOREIGN KEY (id_treno) REFERENCES public.treno(matricola) ON DELETE CASCADE;


--
-- TOC entry 3621 (class 2606 OID 24685)
-- Name: fermate fermate_id_tratta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.fermate
    ADD CONSTRAINT fermate_id_tratta_fkey FOREIGN KEY (id_tratta) REFERENCES public.tratta(id_tratta) ON DELETE CASCADE;


--
-- TOC entry 3622 (class 2606 OID 24690)
-- Name: fermate fermate_stazione_fkey; Type: FK CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.fermate
    ADD CONSTRAINT fermate_stazione_fkey FOREIGN KEY (id_stazione) REFERENCES public.stazione(id_stazione) ON DELETE CASCADE;


--
-- TOC entry 3613 (class 2606 OID 24649)
-- Name: biglietto fk_biglietto_prenotazione; Type: FK CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.biglietto
    ADD CONSTRAINT fk_biglietto_prenotazione FOREIGN KEY (id_prenotazione) REFERENCES public.prenotazione(id_prenotazione) ON DELETE CASCADE;


--
-- TOC entry 3614 (class 2606 OID 24669)
-- Name: biglietto fk_biglietto_tipologia; Type: FK CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.biglietto
    ADD CONSTRAINT fk_biglietto_tipologia FOREIGN KEY (id_tipologia) REFERENCES public.tipologia_biglietto(id_tipologia) ON DELETE CASCADE;


--
-- TOC entry 3619 (class 2606 OID 24674)
-- Name: prenotazione fk_prenotazione_pagamento; Type: FK CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.prenotazione
    ADD CONSTRAINT fk_prenotazione_pagamento FOREIGN KEY (id_metodo_pagamento) REFERENCES public.metodo_pagamento(id_metodo_pagamento) ON DELETE SET NULL;


--
-- TOC entry 3620 (class 2606 OID 24629)
-- Name: prenotazione prenotazione_id_passeggero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.prenotazione
    ADD CONSTRAINT prenotazione_id_passeggero_fkey FOREIGN KEY (id_passeggero) REFERENCES public.passeggero(id_passeggero) ON DELETE CASCADE;


--
-- TOC entry 3615 (class 2606 OID 16484)
-- Name: tratta tratta_id_stazione_arrivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.tratta
    ADD CONSTRAINT tratta_id_stazione_arrivo_fkey FOREIGN KEY (id_stazione_arrivo) REFERENCES public.stazione(id_stazione) ON DELETE CASCADE;


--
-- TOC entry 3616 (class 2606 OID 16479)
-- Name: tratta tratta_id_stazione_partenza_fkey; Type: FK CONSTRAINT; Schema: public; Owner: antoniocannistra
--

ALTER TABLE ONLY public.tratta
    ADD CONSTRAINT tratta_id_stazione_partenza_fkey FOREIGN KEY (id_stazione_partenza) REFERENCES public.stazione(id_stazione) ON DELETE CASCADE;


--
-- TOC entry 3784 (class 0 OID 24580)
-- Dependencies: 230 3792
-- Name: tratte_giornaliere; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: antoniocannistra
--

REFRESH MATERIALIZED VIEW public.tratte_giornaliere;


-- Completed on 2025-04-30 10:36:47 CEST

--
-- PostgreSQL database dump complete
--

