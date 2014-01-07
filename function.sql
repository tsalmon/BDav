DROP FUNCTION IF EXISTS ouvrir_compte(t_name varchar, v_iban varchar, v_solde integer, v_bic varchar, v_id varchar);
CREATE FUNCTION choix_compte(t_name varchar, v_iban varchar, v_solde integer, v_bic varchar, v_id varchar) RETURNS VARCHAR AS $_$
       DECLARE
                retour varchar;
       BEGIN
                  IF (t_name = 'particulier') THEN
			INSERT INTO compte_particulier ("IBAN", solde, "BIC_banque", id_client_particulier) 
			VALUES (v_iban, v_solde, v_bic, v_id);
			retour := 'ok';
                  ELSIF (t_name = 'pro') THEN
                        INSERT INTO compte_pro ("IBAN", solde, "BIC_banque", id_client_organisation) 
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

DROP FUNCTION IF EXISTS virement_compte_permanent(d date, fq integer, bene varchar, eme varchar, mont integer);
CREATE FUNCTION virement_compte_permanent(d date, fq integer, bene varchar, eme varchar, mont integer) RETURNS VOID AS $_$
	BEGIN
		INSERT INTO virement_permanent (date, frequence, beneficiaire, emeteur, montant) 
		VALUES (d, fq , bene, eme, mont);
	RETURN;
END $_$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS trigger_data ON "Date";
DROP FUNCTION IF EXISTS trig_data();
CREATE FUNCTION trig_data() RETURNS TRIGGER AS $_$
	DECLARE
		aux RECORD;
		date_act date;		
		add_freq date;
	BEGIN
		--taux interet
		UPDATE compte SET solde = solde + solde * (SELECT banque.taux_interet FROM banque 
		WHERE compte."BIC_banque" = banque."BIC");
	
		--virement permanents
			
		SELECT date_actuelle FROM "Date" WHERE id = 1 INTO date_act;	

		FOR aux IN
			SELECT beneficiaire, emeteur, montant FROM virement_permanent 
			WHERE date = date_act 							
		LOOP
			virement_compte(TRUE, aux.beneficiare, aux.emeteur, aux.montant);
			add_freq := cast(cast(aux.freq as varchar) || ' months' as interval);
			UPDATE virement_permanent SET "date" = "date" + add_freq;
		END LOOP;
		
	RETURN OLD;
END $_$ LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_data AFTER UPDATE ON "Date"
FOR EACH ROW 
    EXECUTE PROCEDURE trig_data();

DROP FUNCTION IF EXISTS modifier_date(a_m_j varchar, nb integer);
CREATE FUNCTION modifier_date(amj varchar, nb integer) RETURNS DATE AS $_$
	DECLARE
		choix varchar;
		date_actu date;
		date_futur date;
	BEGIN
		IF(amj = 'annee') THEN
			choix := nb::varchar || ' years ';
		ELSIF(amj = 'mois') THEN
			choix := nb::varchar || ' months ';
		ELSIF(amj = 'jour') THEN
			choix := nb::varchar || ' days';
		ELSE
			RETURN '?';
		END IF;
		
		SELECT date_actuelle FROM "Date" WHERE id = 1 
		INTO date_actu;		
		SELECT date_actu::date + cast(choix as interval) INTO date_futur;

		WHILE date_futur != date_actu
		LOOP
			UPDATE "Date" SET date_actuelle = date_actu + 1 WHERE id = 1;
			SELECT date_actuelle FROM "Date" WHERE id = 1 INTO date_actu;
		END LOOP;

		RETURN date_futur;
END $_$ LANGUAGE 'plpgsql';


       --INSERT INTO article2 (article_id, article_name) VALUES (OLD.article_id, OLD.article_name);
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

