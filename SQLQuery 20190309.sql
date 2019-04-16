---wyra�enia CTE
With nazwa as (polecenie_sql1),(polecenie_sql2)

polecenie SQL
(np. select * from polecenie_sql1 union select * from polecenie_sql2)


---poka� dane pacjent�w, zaweiraj�ce nazwisko,imi�, pesel dla tych pacjent�w, kt�rzy pomi�dzy czerwcem z listopadem 2012 byli na wizycie u kardiologa a  tak�e u diabetologa
With WizKar as
    (SELECT Pacjenci.IdPacjenta,
        Pacjenci.Nazwisko,
        Pacjenci.Imie,
        Pacjenci.Pesel,
        Specjalizacje.NazwaSpecjalizacji
    FROM Pacjenci
    JOIN Wizyty
        ON Pacjenci.IdPacjenta=Wizyty.IdPacjenta
    JOIN Lekarze
        ON Wizyty.IdLekarza=Lekarze.IdLekarza
    JOIN Specjalizacje
        ON Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji
    WHERE Specjalizacje.NazwaSpecjalizacji='kardiolog'
            AND Wizyty.DataWizyty
        BETWEEN '2012-06-01'
            AND '2012-11-30'), 
		
			WizDia as

    (SELECT Pacjenci.IdPacjenta,
        Pacjenci.Nazwisko,
        Pacjenci.Imie,
        Pacjenci.Pesel,
        Specjalizacje.NazwaSpecjalizacji
    FROM Pacjenci
    JOIN Wizyty
        ON Pacjenci.IdPacjenta=Wizyty.IdPacjenta
    JOIN Lekarze
        ON Wizyty.IdLekarza=Lekarze.IdLekarza
    JOIN Specjalizacje
        ON Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji
    WHERE Specjalizacje.NazwaSpecjalizacji='diabetolog'
            AND Wizyty.DataWizyty
        BETWEEN '2012-06-01'
            AND '2012-11-30') 

SELECT WizKar.Nazwisko,
        WizKar.Imie,
        WizKar.Pesel
FROM WizKar intersectSELECT WizDia.Nazwisko,
        WizDia.Imie,
        WizDia.Pesel
FROM WizDia 

---poka� dane pacjent�w, zaweiraj�ce nazwisko,imi�, pesel dla tych pacjent�w, kt�rzy pomi�dzy czerwcem z listopadem 2012 byli na wizycie u kardiologa a  tak�e u diabetologa (z jednym wyra�eniem CTE)
With WizKarDia as
    (SELECT Pacjenci.IdPacjenta,
        Pacjenci.Nazwisko,
        Pacjenci.Imie,
        Pacjenci.Pesel,
        Specjalizacje.NazwaSpecjalizacji
    FROM Pacjenci
    JOIN Wizyty
        ON Pacjenci.IdPacjenta=Wizyty.IdPacjenta
    JOIN Lekarze
        ON Wizyty.IdLekarza=Lekarze.IdLekarza
    JOIN Specjalizacje
        ON Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji
    WHERE Specjalizacje.NazwaSpecjalizacji='kardiolog'
            AND Wizyty.DataWizyty
        BETWEEN '2012-06-01'
            AND '2012-11-30'
            AND Pacjenci.IdPacjenta IN 
        (SELECT Pacjenci.IdPacjenta
        FROM Pacjenci
        JOIN Wizyty
            ON Pacjenci.IdPacjenta=Wizyty.IdPacjenta
        JOIN Lekarze
            ON Wizyty.IdLekarza=Lekarze.IdLekarza
        JOIN Specjalizacje
            ON Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji
        WHERE Specjalizacje.NazwaSpecjalizacji='diabetolog'
                AND Wizyty.DataWizyty
            BETWEEN '2012-06-01'
                AND '2012-11-30') )

SELECT WizKarDia.Nazwisko,
        WizKarDia.Imie,
        WizKarDia.Pesel
FROM WizKarDia 


Pacjenci.IdPacjenta from Pacjenci join Wizyty on Pacjenci.IdPacjenta=Wizyty.IdPacjenta join Lekarze on Wizyty.IdLekarza=Lekarze.IdLekarza join Specjalizacje on Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji where Specjalizacje.NazwaSpecjalizacji='diabetolog' and Wizyty.DataWizyty between '2012-06-01' and '2012-11-30'



---ZADANIE 8. W bazie danych EP50_Przychodnia przygotowa� zestawienie zawieraj�ce dane lekarzy(nazwisko, imi�, numer ewidencyjny i nazw� specjalizacji), kt�rzy w roku 2012 osi�gn�li wi�ksz� sum� op�at za wizyty ni� w roku 2013.  Uwzgl�dniamy jedynie op�aty za wizyty pe�noletnich pacjent�w. W wyniku zapytania uwzgl�dniamy tych lekarzy kt�rzy osi�gn�li poziom op�at za wizyty w roku 2012 wi�kszy o 20% od sumy op�at za rok 2013.(Zaczynamy od wyra�e� CTE - suma wp�at za wizyty dla poszczeg�lnych lekarzy)
with suma2012 as
    (SELECT Wizyty.IdLekarza,
        SUM(Wizyty.Oplata) AS s2012
    FROM Wizyty
    JOIN Pacjenci
        ON Wizyty.IdPacjenta=Pacjenci.IdPacjenta
    WHERE YEAR(Wizyty.DataWizyty) - YEAR(Pacjenci.DataUrodzenia) >17
            AND YEAR(Wizyty.DataWizyty) = 2012
    GROUP BY  Wizyty.IdLekarza),

suma2013 as

    (SELECT Wizyty.IdLekarza,
        SUM(Wizyty.Oplata) AS s2013
    FROM Wizyty
    JOIN Pacjenci
        ON Wizyty.IdPacjenta=Pacjenci.IdPacjenta
    WHERE YEAR(Wizyty.DataWizyty) - YEAR(Pacjenci.DataUrodzenia) >17
            AND YEAR(Wizyty.DataWizyty) = 2013
    GROUP BY  Wizyty.IdLekarza)

SELECT Lekarze.Nazwisko,
        Lekarze.Imie,
        Lekarze.NrEwid,
        Specjalizacje.NazwaSpecjalizacji
FROM Lekarze
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
JOIN suma2012
    ON suma2012.IdLekarza=Lekarze.IdLekarza
JOIN suma2013
    ON Lekarze.IdLekarza=suma2013.IdLekarza
WHERE suma2012.s2012>1.2*suma2013.s2013

	--ZADANIE 14. W bazie EP50_Przychodnia przygotuj zapytanie zwracaj�ce nast�puj�ce dane; nazwisko, imi�  i nazw� specjalizacji tych lekarzy, kt�rzy w maju 2012 przyj�li przynajmniej 5 pacjentek urodzonych przed rokiem 1950
With PacjMaj50 as (
SELECT Wizyty.IdLekarza,
        Wizyty.IdWizyty
FROM Wizyty
JOIN Pacjenci
    ON Wizyty.IdPacjenta=Pacjenci.IdPacjenta
WHERE Wizyty.DataWizyty
    BETWEEN '2012-05-01'
        AND '2012-05-31'
        AND Pacjenci.CzyKobieta=1
        AND YEAR(Pacjenci.DataUrodzenia)<1950 )

SELECT Lekarze.Nazwisko,
        Lekarze.Imie,
        Specjalizacje.NazwaSpecjalizacji,
        COUNT(PacjMaj50.IdWizyty)
FROM Lekarze
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
JOIN PacjMaj50
    ON PacjMaj50.IdLekarza=Lekarze.IdLekarza
GROUP BY  Lekarze.Nazwisko,Lekarze.Imie,Specjalizacje.NazwaSpecjalizacji
HAVING COUNT(PacjMaj50.IdWizyty)>=5



---ZADANIE 17. W bazie danych EP50_Przychodnia napisa� zapytanie, kt�re zwr�ci nast�puj�ce dane; nazwisko, imi� i rok urodzenia dla tych pacjentek, kt�re w roku 2012 by�y przynajmniej dwa razy u kardiologa.

with PacjaKard2012 as (
SELECT Pacjenci.IdPacjenta,
        Wizyty.IdWizyty
FROM Pacjenci
JOIN Wizyty
    ON Wizyty.IdPacjenta=Pacjenci.IdPacjenta
JOIN Lekarze
    ON Wizyty.IdLekarza=Lekarze.IdLekarza
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
WHERE Pacjenci.CzyKobieta=1
        AND year(Wizyty.DataWizyty)=2012
        AND Specjalizacje.NazwaSpecjalizacji='kardiolog' )

SELECT Pacjenci.Nazwisko,
        Pacjenci.Imie,
        YEAR(Pacjenci.DataUrodzenia),
        COUNT(PacjaKard2012.IdWizyty)
FROM Pacjenci
JOIN PacjaKard2012
    ON Pacjenci.IdPacjenta=PacjaKard2012.IdPacjenta
GROUP BY  Pacjenci.Nazwisko,Pacjenci.Imie,YEAR(Pacjenci.DataUrodzenia)
HAVING COUNT(PacjaKard2012.IdWizyty) >1


---ZADANIE 20. W bazie EP50_Przychodnia napisa� zapytanie, kt�re zwr�ci dane pacjentek urodzonych po roku 1965; nazwisko, imi� i pesel, kt�re w roku 2013 mia�y przynajmniej trzy wizyty u lekarza rodzinnego i przynajmniej 3 wizyty u innych specjalist�w.
with rodzinny as (
SELECT Pacjenci.Nazwisko,
        Pacjenci.Imie,
        Pacjenci.Pesel
FROM Pacjenci
JOIN Wizyty
    ON Pacjenci.IdPacjenta=Wizyty.IdPacjenta
JOIN Lekarze
    ON Wizyty.IdLekarza=Lekarze.IdLekarza
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
WHERE year(Pacjenci.DataUrodzenia)>1965
        AND Pacjenci.CzyKobieta=1
        AND year(Wizyty.DataWizyty)=2013
        AND Specjalizacje.NazwaSpecjalizacji='lekarz rodzinny'
GROUP BY  Pacjenci.Nazwisko,Pacjenci.Imie,Pacjenci.Pesel
HAVING COUNT(Wizyty.IdWizyty)>1 ),

inny as (
SELECT Pacjenci.Nazwisko,
        Pacjenci.Imie,
        Pacjenci.Pesel
FROM Pacjenci
JOIN Wizyty
    ON Pacjenci.IdPacjenta=Wizyty.IdPacjenta
JOIN Lekarze
    ON Wizyty.IdLekarza=Lekarze.IdLekarza
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
WHERE year(Pacjenci.DataUrodzenia)>1965
        AND Pacjenci.CzyKobieta=1
        AND year(Wizyty.DataWizyty)=2013
        AND Specjalizacje.NazwaSpecjalizacji!='lekarz rodzinny'
GROUP BY  Pacjenci.Nazwisko,Pacjenci.Imie,Pacjenci.Pesel
HAVING COUNT(Wizyty.IdWizyty)>1 )

SELECT *
FROM rodzinny 
intersect
SELECT *
FROM inny


---ZADANIE 22 W bazie EP50_Przychodnia napisa� zapytanie, kt�re przygotuje nast�puj�ce dane; nazwisko, imi� i nazw� specjalizacji tych lekarzy, kt�rzy w roku 2013 przyj�li na wizytach wi�cej m�czyzn ni� kobiet. Uwzgl�dniamy tylko tych lekarzy, kt�rzy w roku 2013 osi�gn�li sumaryczna op�at� za wizyty wi�ksz� ni� 80000 PLN.

with WizM as (
SELECT Wizyty.IdLekarza,
        COUNT(Wizyty.IdWizyty) AS ilosc
FROM Wizyty
JOIN Pacjenci
    ON Wizyty.IdPacjenta=Pacjenci.IdPacjenta
WHERE Pacjenci.CzyKobieta=0
        AND YEAR(Wizyty.DataWizyty)=2013
GROUP BY  Wizyty.IdLekarza ),


WizK as (
SELECT Wizyty.IdLekarza,
        COUNT(Wizyty.IdWizyty) AS ilosc
FROM Wizyty
JOIN Pacjenci
    ON Wizyty.IdPacjenta=Pacjenci.IdPacjenta
WHERE Pacjenci.CzyKobieta=1
        AND YEAR(Wizyty.DataWizyty)=2013
GROUP BY  Wizyty.IdLekarza ),


Lek80 as (
SELECT Lekarze.IdLekarza,
        Lekarze.Nazwisko,
        Lekarze.Imie,
        Specjalizacje.NazwaSpecjalizacji,
        SUM(Wizyty.Oplata) AS suma
FROM Lekarze
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
JOIN Wizyty
    ON Wizyty.IdLekarza=Lekarze.IdLekarza
WHERE year(Wizyty.DataWizyty)=2013
GROUP BY  Lekarze.IdLekarza,Lekarze.Nazwisko,Lekarze.Imie,Specjalizacje.NazwaSpecjalizacji
HAVING SUM(Wizyty.Oplata) >80000 )


SELECT Lek80.nazwisko,
        lek80.imie,
        lek80.nazwaspecjalizacji
FROM Lek80
JOIN WizM
    ON Lek80.IdLekarza=WizM.IdLekarza
JOIN WizK
    ON Lek80.IdLekarza=WizK.IdLekarza
WHERE WizM.ilosc>WizK.Ilosc 


---ZADANIE 24 W bazie danych EP50_Przychodnia napisa� zapytanie, kt�re zwraca nast�puj�ce dane; nazwisko, imi� i nazw� specjalizacji  lekarza, ilo�� wizyt oraz sumaryczna op�at� za wizyty w roku 2013. Do oblicze� uwzgl�dniamy tylko wizyty tych pacjent�w, kt�rzy w 2012 nie byli ani razu u kardiologa. W wyniku uwzgl�dniamy tych lekarzy, kt�rzy obs�u�yli wi�cej ni� 400 wizyty i osi�gn�li sumaryczn� op�at� za wizyty wi�ksz� ni� 90000 PLN.

with 
Lek13 as (
SELECT Lekarze.IdLekarza,
        Lekarze.Nazwisko,
        Lekarze.Imie,
        Specjalizacje.NazwaSpecjalizacji,
        count(Wizyty.IdWizyty) AS ilosc,
        SUM(Wizyty.Oplata) AS suma
FROM Lekarze
JOIN Wizyty
    ON Lekarze.IdLekarza=Wizyty.IdLekarza
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
WHERE Wizyty.IdPacjenta IN 
    (SELECT DISTINCT Pacjenci.IdPacjenta
    FROM Pacjenci
    JOIN Wizyty
        ON Wizyty.IdPacjenta=Pacjenci.IdPacjenta
    JOIN Lekarze
        ON Lekarze.IdLekarza=Wizyty.IdLekarza
    JOIN Specjalizacje
        ON Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji
    WHERE YEAR(Wizyty.DataWizyty)=2012
            AND Specjalizacje.NazwaSpecjalizacji!='kardiolog')
GROUP BY  Lekarze.IdLekarza, Lekarze.Nazwisko,Lekarze.Imie,Specjalizacje.NazwaSpecjalizacji
HAVING COUNT(Wizyty.IdWizyty) >400
        AND SUM(Wizyty.Oplata) >90000 )



SELECT  Lek13.IdLekarza,
        lek13.Nazwisko,
        Lek13.Imie,
        Lek13.nazwaspecjalizacji,
        Lek13.ilosc,
        Lek13.suma
FROM Lek13 


---rozwi�zanie Micha�a

WITH Pac12 �as (
SELECT Pacjenci.IdPacjenta,
         Lekarze.IdLekarza
FROM Pacjenci
JOIN �Wizyty
    ON Wizyty.IdPacjenta=Pacjenci.IdPacjenta
JOIN Lekarze
    ON Lekarze.IdLekarza=Wizyty.IdLekarza
JOIN Specjalizacje
    ON Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji
WHERE YEAR(Wizyty.DataWizyty)=2012
        AND Specjalizacje.NazwaSpecjalizacji!='Kardiolog' ),

Lek13 as (
SELECT Lekarze.IdLekarza,
         Lekarze.Nazwisko,
         Lekarze.Imie,
         Specjalizacje.NazwaSpecjalizacji,
         COUNT(Wizyty.IdWizyty) AS ilosc,
         SUM(Wizyty.Oplata) AS suma
FROM Lekarze
JOIN Specjalizacje
    ON Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji
JOIN �Wizyty
    ON Wizyty.IdLekarza=Lekarze.IdLekarza
GROUP BY  �Lekarze.IdLekarza, Lekarze.Nazwisko, Lekarze.Imie, Specjalizacje.NazwaSpecjalizacji
HAVING COUNT(Wizyty.IdWizyty) >400
        AND �SUM(Wizyty.Oplata) >90000)


SELECT DISTINCT �Lek13.IdLekarza,
         Lek13.Nazwisko,
         Lek13.Imie,
         Lek13.NazwaSpecjalizacji,
         Lek13.suma,
         Lek13.ilosc
FROM Lek13
JOIN �Pac12
    ON Lek13.IdLekarza=Pac12.IdLekarza



---ZADANIE 25 W bazie danych EP50_Przychodnia napisa� zapytanie, kt�re zwr�ci dane pacjent�w (nazwisko, imi�, pesel i p�e�), tych pacjent�w, kt�rzy w maju 2012 byli na wizytach u przynajmniej dw�ch lekarzy r�nych specjalizacji
with Pac2Lek as (
SELECT DISTINCT Wizyty.IdPacjenta,
        count(Lekarze.Idspecjalizacji) AS ilosc
FROM Wizyty
JOIN Lekarze
    ON Lekarze.IdLekarza = Wizyty.IdLekarza
WHERE Wizyty.DataWizyty
    BETWEEN '2012-05-01'
        AND '2012-05-31'
GROUP BY  Wizyty.IdPacjenta
HAVING count(Lekarze.Idspecjalizacji)>1 )


SELECT Pacjenci.Nazwisko,
        Pacjenci.Imie,
        Pacjenci.Pesel,
         iif(Pacjenci.CzyKobieta=1,
        'kobieta','m�czyzna') AS plec
FROM Pacjenci
JOIN Pac2Lek
    ON Pacjenci.IdPacjenta=Pac2Lek.IdPacjenta


---ZADANIE 27 W bazie danych EP50_Przychodnia napisa� zapytanie zwracaj�ce nast�puj�ce dane: nazwisko, imi�, pesel i p�e� tych pacjent�w, kt�rzy w pierwszym p�roczu 2013 byli u diabetologa i chirurga.

with Uchir as (
SELECT Pacjenci.Nazwisko,
        Pacjenci.Imie,
        Pacjenci.Pesel,
        IIF(Pacjenci.CzyKobieta=1,
        'kobieta','m�czyzna') AS plec
FROM Pacjenci
JOIN Wizyty
    ON Pacjenci.IdPacjenta=Wizyty.IdPacjenta
JOIN Lekarze
    ON Lekarze.IdLekarza=Wizyty.IdLekarza
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
WHERE Wizyty.DataWizyty
    BETWEEN '2013-01-01'
        AND '2013-06-30'
        AND Specjalizacje.NazwaSpecjalizacji='chirurg' ),

Udiab as (
SELECT Pacjenci.Nazwisko,
        Pacjenci.Imie,
        Pacjenci.Pesel,
        IIF(Pacjenci.CzyKobieta=1,
        'kobieta','m�czyzna') AS plec
FROM Pacjenci
JOIN Wizyty
    ON Pacjenci.IdPacjenta=Wizyty.IdPacjenta
JOIN Lekarze
    ON Lekarze.IdLekarza=Wizyty.IdLekarza
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
WHERE Wizyty.DataWizyty
    BETWEEN '2013-01-01'
        AND '2013-06-30'
        AND Specjalizacje.NazwaSpecjalizacji='diabetolog' )


SELECT *
FROM Uchir
intersect
SELECT *
FROM Udiab


