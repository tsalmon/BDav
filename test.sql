-- test ouvrir/retrait/fermer un compte
SELECT * FROM ouvrir_compte('pro', '666', 666, '0', '3');
SELECT * FROM ouvrir_compte('pro', '999', 10101, '0', '3');
SELECT * FROM compte WHERE "IBAN"='666'  OR "IBAN"='999';
SELECT * FROM retrait_compte('666', 10);
SELECT * FROM virement_compte(FALSE, '666', '999', 100);
SELECT * FROM compte WHERE "IBAN"='666' OR "IBAN"='999';
SELECT * FROM suppr_compte('666');
SELECT * FROM suppr_compte('999');