-- GET CONVERSATIONS
SELECT
    CONCAT(
        IF(
            mittente_messaggio > destinatario_messaggio,
            CONCAT(
                mittente_messaggio,
                '_',
                destinatario_messaggio
            ),
            CONCAT(
                destinatario_messaggio,
                '_',
                mittente_messaggio
            )
        ),
        '_',
    REPLACE
        (oggetto_messaggio, 'Re%3A%20', '')
    ) AS temp_id
FROM
    messaggi_ingioco
GROUP BY
    temp_id
ORDER BY
    temp_id ASC,
    id_messaggio ASC