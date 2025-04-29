--Verifica il numero di posti rimanenti per una determinata tratta (SISTEMATO)
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
         JOIN biglietto b ON b.id_tratta = t.id_tratta AND b.data_annullamento IS NULL
WHERE s1.nome = 'Milazzo Centrale' AND s2.nome = 'Messina Centrale'  AND e.partenza_prevista = '2025-04-28 17:32:51.000000'
GROUP BY t.id_tratta, s1.nome, s2.nome, tr.numero_posti, e.partenza_prevista,tr.matricola;

--Verifica le fermate di una determinata tratta (SISTEMATO)
SELECT
    t.id_tratta,
    s.nome "Fermate",
    TO_CHAR(f.partenza_prevista,'DD/MM/YYYY HH24:MI') "Partenza prevista",
    TO_CHAR(f.partenza_effettiva,'DD/MM/YYYY HH24:MI') "Partenza effettiva"
FROM tratta t
         JOIN fermate f ON t.id_tratta = f.id_tratta
         JOIN stazione s ON f.id_stazione = s.id_stazione
         JOIN stazione s_tratta_partenza ON s_tratta_partenza.id_stazione = t.id_stazione_partenza
         JOIN stazione s_tratta_arrivo ON s_tratta_arrivo.id_stazione = t.id_stazione_arrivo
WHERE
        s_tratta_partenza.nome = 'Napoli Centrale' AND s_tratta_arrivo.nome = 'Milano Centrale';
        --t.id_tratta = 1;


--Visualizza tutti i biglietti acquistati da un determinato passeggero (SISTEMATA)
SELECT p.id_prenotazione, TO_CHAR(b.data_emissione, 'DD/MM/YYYY HH24:MI') AS "Data emissione",
       tb.descrizione AS "Tipologia Biglietto", s_partenza.nome AS "Stazione di partenza",
       s_arrivo.nome AS "Stazione di arrivo", b.prezzo AS "Prezzo"
FROM biglietto b
         JOIN prenotazione p on b.id_prenotazione = p.id_prenotazione
         JOIN tratta t ON b.id_tratta = t.id_tratta
         JOIN stazione s_partenza ON t.id_stazione_partenza = s_partenza.id_stazione
         JOIN stazione s_arrivo ON t.id_stazione_arrivo = s_arrivo.id_stazione
         JOIN passeggero pass ON p.id_passeggero = pass.id_passeggero
         JOIN tipologia_biglietto tb ON b.id_tipologia = tb.id_tipologia
WHERE
  --pass.id_passeggero = 1
    pass.nome = 'Antonio' AND pass.cognome = 'Cannistrà'
ORDER BY p.prezzo_totale;

-- Verifica validità di tutti i biglietti relativi a una tratta comprensivi di nominativo (SISTEMATO)
SELECT
    pass.nome,
    pass.cognome,
    b.data_validazione AS "Validato"
FROM
    prenotazione p
        JOIN passeggero pass ON pass.id_passeggero = p.id_passeggero
        JOIN biglietto b ON b.id_prenotazione = p.id_prenotazione
        JOIN tratta t ON b.id_tratta = t.id_tratta
        JOIN stazione s1 ON s1.id_stazione = t.id_stazione_partenza
        JOIN stazione s2 ON s2.id_stazione = t.id_stazione_arrivo
        JOIN effettua e ON t.id_tratta = e.id_tratta
WHERE
    s1.nome = 'Milazzo Centrale'
  AND s2.nome = 'Messina Centrale'
  AND e.partenza_prevista = '2025-04-28 17:32:51.000000';

--Visualizza il numero di minuti di ritardo di uno specifico treno in partenza (SISTEMATO)
SELECT
    e.partenza_prevista,
    e.partenza_effettiva,
    TO_CHAR(e.partenza_effettiva - e.partenza_prevista, 'HH24:MI')  "Ritardo (hh:mm)"
FROM effettua e
         JOIN tratta t ON e.id_tratta = t.id_tratta
         JOIN stazione s1 ON s1.id_stazione = t.id_stazione_partenza
         JOIN stazione s2 ON s2.id_stazione = t.id_stazione_arrivo
WHERE
    s1.nome = 'Milazzo Centrale'
    AND s2.nome = 'Messina Centrale'
    AND e.partenza_prevista = '2025-04-28 17:32:51.000000';

--Visualizza i recapiti di tutti i clienti con i relativi dati anagrafici, se non c’è la partita iva, visualizzare il codice fiscale
SELECT
    p.nome,
    p.cognome,
    (p.via,p.numero_civico,p.cap,p.citta,p.nazione) "indirizzo",
    COALESCE(p.p_iva,p.cf, 'NESSUN DATO') AS "codice di riconoscimento"
FROM passeggero p;

--creazione vista materializzata per le tratte giornaliere

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

