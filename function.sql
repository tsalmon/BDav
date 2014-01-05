DROP FUNCTION IF EXISTS choix_compte(t_name varchar, v_iban varchar, v_solde integer, v_bic varchar, v_id varchar);
CREATE FUNCTION choix_compte(t_name varchar, v_iban varchar, v_solde integer, v_bic varchar, v_id varchar) RETURNS VARCHAR AS $_$
       DECLARE
                retour varchar;
       BEGIN
                  IF (t_name = 'particulier') THEN
			INSERT INTO compte_particulier ("IBAN", solde, "BIC_banque", id_client_particulier) 
			VALUES (v_iban, v_solde, v_bic, v_id);
			retour := 'ok';
                  ELSIF (t_name = 'pro') THEN
                        INSERT INTO compte_pro ("IBAN", solde, "BIC_banque", id_client_pro) 
			VALUES (v_iban, v_solde, v_bic, v_id);
                        retour := 'ok';
                  ELSE
                       retour := 'pas bon';
                  END IF;
       RETURN retour;
END $_$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS suppr_compte(v_iban varchar);
CREATE FUNCTION suppr_compte(v_iban varchar) RETURNS VOID AS $_$
       BEGIN
              DELETE FROM compte WHERE "IBAN" = v_iban;                        
       RETURN;
END $_$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS retrait_compte(v_iban varchar, v_montant integer);
CREATE FUNCTION retrait_compte(v_iban varchar, v_montant integer) RETURNS VOID AS $_$
	BEGIN
		UPDATE compte
		SET solde = solde - v_montant
		WHERE "IBAN" = v_iban;
	RETURN;
END $_$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS virement_compte(v_perm boolean,v_iban1 varchar, v_iban2 varchar, v_montant integer);
CREATE FUNCTION virement_compte(v_perm boolean, v_iban1 varchar, v_iban2 varchar, v_montant integer) RETURNS VOID AS $_$
       	DECLARE
		prix_vir integer ;
		bic1 varchar;
		bic2 varchar;
	BEGIN
		SELECT "BIC_banque" INTO bic1 FROM compte WHERE "IBAN" = v_iban1;
		SELECT "BIC_banque" INTO bic2 FROM compte WHERE "IBAN" = v_iban2;

		IF (v_perm = FALSE AND bic1 != bic2) THEN
		   SELECT prix_virement INTO prix_vir FROM banque WHERE "BIC" = bic1;
		ELSIF (v_perm = TRUE AND bic1 != bic2) THEN
		   SELECT prix_virement_mensuel INTO prix_vir FROM banque WHERE "BIC" = bic1;
		ELSE 
		   prix_vir := 0;
		END IF;		
		UPDATE compte SET solde = solde - v_montant - prix_vir WHERE "IBAN" = v_iban1;
		UPDATE compte SET solde = solde + v_montant WHERE "IBAN" = v_iban2;
		-- on ajoute a l'historique
		INSERT INTO virement (emeteur, beneficiaire, montant) VALUES (v_iban1, v_iban2 , v_montant);
	RETURN;
END $_$ LANGUAGE 'plpgsql';

/*
DROP FUNCTION IF EXISTS interdir_compte(v_perm boolean,v_iban1 varchar, v_iban2 varchar, v_montant integer);
CREATE FUNCTION interdir_compte(v_perm boolean, v_iban1 varchar, v_iban2 varchar, v_montant integer) RETURNS VOID AS $_$
       	DECLARE
		prix_vir integer ;
		bic1 varchar;
		bic2 varchar;
	BEGIN
		SELECT "BIC_banque" INTO bic1 FROM compte WHERE "IBAN" = v_iban1;
		SELECT "BIC_banque" INTO bic2 FROM compte WHERE "IBAN" = v_iban2;

		IF (v_perm = FALSE AND bic1 != bic2) THEN
		   SELECT prix_virement INTO prix_vir FROM banque WHERE "BIC" = bic1;
		ELSIF (v_perm = TRUE AND bic1 != bic2) THEN
		   SELECT prix_virement_mensuel INTO prix_vir FROM banque WHERE "BIC" = bic1;
		ELSE 
		   prix_vir := 0;
		END IF;		
		UPDATE compte SET solde = solde - v_montant - prix_vir WHERE "IBAN" = v_iban1;
		UPDATE compte SET solde = solde + v_montant WHERE "IBAN" = v_iban2;
		-- on ajoute a l'historique
		INSERT INTO virement (emeteur, beneficiaire, montant) VALUES (v_iban1, v_iban2 , v_montant);
	RETURN;
END $_$ LANGUAGE 'plpgsql';
*/
