--Verifica il numero di posti rimanenti per una determinata tratta
SELECT
    t.id_tratta,
    s1.nome "Stazione di partenza",
    s2.nome "Stazione di arrivo",
    TO_CHAR(e.partenza_prevista, 'DD/MM/YYYY HH24:MI') "Data partenza prevista",
    --e.partenza_prevista "Data partenza prevista",
    tr.matricola "Matricola treno",
    tr.numero_posti "Numero posti totali",
    (tr.numero_posti - COALESCE(COUNT(b.id_biglietto), 0)) "Posti rimanenti"
FROM effettua e
         JOIN tratta t ON e.id_tratta = t.id_tratta
         JOIN stazione s1 ON t.id_stazione_partenza = s1.id_stazione
         JOIN stazione s2 ON t.id_stazione_arrivo = s2.id_stazione
         JOIN treno tr ON e.id_treno = tr.matricola
         JOIN prezzo p ON p.id_tratta = t.id_tratta
         JOIN biglietto b ON b.id_prezzo = p.id_prezzo AND b.data_annullamento IS NULL
WHERE s1.nome = 'Napoli Centrale' AND s2.nome = 'Milano Centrale'  AND e.partenza_prevista = '2025-03-19 23:59:04.000000'
GROUP BY t.id_tratta, s1.nome, s2.nome, tr.numero_posti, e.partenza_prevista,tr.matricola;

--Verifica i cambi di una determinata tratta
SELECT
    t.id_tratta,
    s1.nome "Stazione di entrata cambio",
    s2.nome "Stazione di uscita cambio",
    TO_CHAR(c.partenza_prevista,'DD/MM/YYYY HH24:MI') "Partenza prevista",
    TO_CHAR(c.partenza_effettiva,'DD/MM/YYYY HH24:MI') "Partenza effettiva"
FROM tratta t
         JOIN cambio c ON t.id_tratta = c.id_tratta
         JOIN stazione s1 ON c.s_entrata = s1.id_stazione
         JOIN stazione s2 ON c.s_uscita = s2.id_stazione
         JOIN stazione s3 ON t.id_stazione_partenza = s3.id_stazione
         JOIN stazione s4 ON t.id_stazione_arrivo = s4.id_stazione
WHERE s3.nome = 'Napoli Centrale' AND s4.nome = 'Milano Centrale';

--Visualizza tutti i biglietti acquistati da un determinato passeggero
SELECT
   s1.nome "Stazione di partenza", s2.nome "Stazione di arrivo", TO_CHAR(b.data_emissione, 'DD/MM/YYYY HH24:MI') "Data emissione", p.prezzo, tb.descrizione
FROM passeggero pass
    JOIN biglietto b ON b.id_passeggero = pass.id_passeggero
    JOIN prezzo p ON b.id_prezzo = p.id_prezzo
    JOIN tipologia_biglietto tb ON tb.id_tipologia = p.id_tipologia_biglietto
    JOIN tratta t ON p.id_tratta = t.id_tratta
    JOIN stazione s1 ON s1.id_stazione = t.id_stazione_partenza
    JOIN stazione s2 ON s2.id_stazione = t.id_stazione_arrivo
WHERE
    --pass.id_passeggero = 1
    pass.nome = 'Antonio' AND pass.cognome = 'Cannistrà'
ORDER BY  p.prezzo;

--Verifica validità di tutti i biglietti relativi ad una tratta comprensivi di nominativo
SELECT
    pass.nome, pass.cognome, b.data_validazione "Validato"
FROM biglietto b
    JOIN passeggero pass ON pass.id_passeggero = b.id_passeggero
    JOIN prezzo p ON b.id_prezzo = p.id_prezzo
    JOIN tratta t ON p.id_tratta = t.id_tratta
    JOIN stazione s1 ON s1.id_stazione = t.id_stazione_partenza
    JOIN stazione s2 ON s2.id_stazione = t.id_stazione_arrivo
    JOIN effettua e ON t.id_tratta = e.id_tratta
WHERE
    s1.nome = 'Napoli Centrale' AND s2.nome = 'Milano Centrale' AND e.partenza_prevista = '2025-03-19 23:59:04.000000';

--Visualizza il numero di minuti di ritardo di uno specifico treno in partenza
SELECT
    e.partenza_prevista,
    e.partenza_effettiva,
    TO_CHAR(e.partenza_effettiva - e.partenza_prevista, 'HH24:MI')  "Ritardo (hh:mm)"
FROM effettua e
         JOIN tratta t ON e.id_tratta = t.id_tratta
         JOIN stazione s1 ON s1.id_stazione = t.id_stazione_partenza
         JOIN stazione s2 ON s2.id_stazione = t.id_stazione_arrivo
WHERE
    s1.nome = 'Napoli Centrale'
    AND s2.nome = 'Milano Centrale'
    AND e.partenza_prevista = '2025-03-19 23:59:04.000000';

--Visualizza i recapiti di tutti i clienti con i relativi dati anagrafici, se non c’è la partita iva, visualizzare il codice fiscale
SELECT
    p.nome,
    p.cognome,
    (p.via,p.numero_civico,p.cap,p.citta,p.nazione) "indirizzo",
    COALESCE(p.p_iva,p.cf, 'NESSUN DATO') AS "codice di riconoscimento"
FROM passeggero p;

--creazione vista materializzata per le tratte giornaliere (inserisci stessa tratta con cambio però)

CREATE MATERIALIZED VIEW tratte_giornaliere AS
select
    s1.nome "Stazione di partenza",
    s2.nome "Stazione di arrivo",
    TO_CHAR(e.partenza_prevista, 'YYYY-MM-DD HH24:MI') "data di partenza prevista",
    COALESCE(TO_CHAR(e.partenza_effettiva, 'YYYY-MM-DD HH24:MI'), 'Non ancora partito')  "data di partenza effettiva",
    tr.matricola "Matricola treno"
FROM effettua e
    JOIN tratta t ON e.id_tratta = t.id_tratta
    JOIN treno tr ON tr.matricola = e.id_treno
    JOIN stazione s1 ON s1.id_stazione = t.id_stazione_partenza
    JOIN stazione s2 ON s2.id_stazione = t.id_stazione_arrivo
WHERE DATE(e.partenza_prevista ) = CURRENT_DATE;