/*funkcja szereguj�ca: 
RANK() -  zwraca pozycj� danego wiersza w rankingu
ROW_NUMBER() - zwraca kolejny numer wiersza wg okre�lonego porz�dku
DENSE_RANK() - zwraca pozycj� wiersza w rankingu w spos�b ci�g�y (je�eli dwa piersze pierwsze maj� t� sam� warto��, to trzeci wiersz na pozycj� nr 2
sk�adnia:
RANK() over (order by �rednia)
*/

-- podaj �redni� ocen poszczeg�lnych student�w oraz ich pozycj� w rankingu

SELECT Studenci.Nazwisko,
        Studenci.Imie,
        AVG(Oceny.Ocena) AS srednia,
        rank()
    OVER (order by avg(oceny.ocena) desc) AS pozycja
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
GROUP BY  Studenci.Nazwisko,Studenci.Imie
ORDER BY  AVG(Oceny.Ocena) desc;


-- podaj �redni� ocen student�w, kt�rzy w rankingu  zajmuj� 20 pierwszych pozycji
with StudenciWgSredniej as
    (SELECT Studenci.Nazwisko,
        Studenci.Imie,
        AVG(Oceny.Ocena) AS srednia,
        rank()
        OVER (order by avg(oceny.ocena) desc) AS pozycja
    FROM Studenci
    JOIN Oceny
        ON Studenci.IdStudenta=Oceny.IdStudenta
    GROUP BY  Studenci.Nazwisko,Studenci.Imie)
SELECT *
FROM StudenciWgSredniej
WHERE pozycja <20


-- podaj �redni� ocen poszczeg�lnych student�w oraz ich pozycj� w rankingu (na r�ne sposoby)

SELECT Studenci.Nazwisko,
        Studenci.Imie,
        AVG(Oceny.Ocena) AS srednia,
        rank() OVER (order by avg(oceny.ocena) desc) AS pozycja1,
        ROW_NUMBER() OVER (order by avg(oceny.ocena) desc) AS pozycja2,
        dense_rank() OVER (order by avg(oceny.ocena) desc) AS pozycja3
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
GROUP BY  Studenci.Nazwisko,Studenci.Imie
ORDER BY  AVG(Oceny.Ocena) desc;


---W bazie EP50_Uczelnia napisa� zapytanie, kt�re zwraca nast�puj�ce dane; nazwisko, imi� i pesel student�w oraz �redni�  ocen policzon� z dziesi�ciu  ostatnich ocen wystawionych w roku 2012. W wyniku uwzgl�dniamy tylko tych student�w, kt�rzy w roku 2012 uzyskali co najmniej 25 ocen.
with OstOceny as
    (SELECT Studenci.Nazwisko,
        Studenci.Imie,
        Studenci.Pesel,
        Oceny.Ocena,
        Oceny.DataOceny,
         row_number()
        OVER (partition by studenci.idstudenta
    ORDER BY  oceny.dataoceny desc) AS nr
    FROM Studenci
    JOIN Oceny
        ON Studenci.IdStudenta=Oceny.IdStudenta
    WHERE YEAR(Oceny.DataOceny)=2012 )
SELECT OstOceny.Nazwisko,
        OstOceny.Imie,
        OstOceny.Pesel,
        AVG(OstOceny.Ocena)
FROM OstOceny
WHERE nr <11
        AND OstOceny.Pesel IN 
    (SELECT Studenci.Pesel
    FROM Studenci
    JOIN Oceny
        ON Studenci.IdStudenta=Oceny.IdStudenta
    WHERE YEAR(Oceny.DataOceny)=2012
    GROUP BY  Studenci.Pesel
    HAVING COUNT(Oceny.IdOceny)>24)
GROUP BY  OstOceny.Nazwisko,OstOceny.Imie,OstOceny.Pesel 

 --podzapytanie
 SELECT Studenci.Pesel
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE YEAR(Oceny.DataOceny)=2012
GROUP BY  Studenci.Pesel
HAVING COUNT(Oceny.IdOceny)>24



 ---W bazie EP50_Uczelnia napisa� zapytanie, kt�re zwraca nast�puj�ce dane; nazwisko, imi� i pesel studentek oraz nazw� przedmiotu , dla tych studentek, kt�re w rankingu ocen z danego przedmiotu s� na drugim miejscu w�r�d studentek i maj� wy�sz� �rednia ocen ni� lider rankingu wed�ug �redniej dla danego przedmiotu w�r�d student�w (m�czyzn).
 with SredM as (
SELECT Studenci.Nazwisko,
        Studenci.Imie,
        Studenci.Pesel,
        Przedmioty.Nazwa,
        AVG(Oceny.ocena) AS SrM,
        ROW_NUMBER()
    OVER (partition by Przedmioty.Nazwa
ORDER BY  AVG(Oceny.ocena) desc) AS NrM
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
WHERE Studenci.CzyKobieta = 0
GROUP BY  Studenci.Nazwisko,Studenci.Imie,Studenci.Pesel,Przedmioty.Nazwa ),

  SredK as (
SELECT Studenci.Nazwisko,
        Studenci.Imie,
        Studenci.Pesel,
        Przedmioty.Nazwa,
        AVG(Oceny.ocena) AS SrK,
        ROW_NUMBER()
    OVER (partition by Przedmioty.Nazwa
ORDER BY  AVG(Oceny.ocena) desc) AS NrK
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
WHERE Studenci.CzyKobieta = 1
GROUP BY  Studenci.Nazwisko,Studenci.Imie,Studenci.Pesel,Przedmioty.Nazwa )

SELECT SredK.Nazwisko,
        SredK.Imie,
        SredK.Pesel,
        SredK.Nazwa
FROM SredK
JOIN SredM
    ON SredK.Nazwa=SredM.Nazwa
WHERE NrK=2
        AND NrM=1
        AND SrK > SrM



 --- W bazie EP50_Uczelnia napisa� zapytanie, kt�re zwr�ci nazw� miesi�ca, rok oraz nazw� przedmiotu w kt�rym z danego przedmiotu uzyskano najwi�cej ocen niedostatecznych.

with abc as (
SELECT YEAR(Oceny.DataOceny) AS rok,
         DATENAME(mm,
         Oceny.DataOceny) AS miesiac,
         Przedmioty.Nazwa,
        COUNT(*) AS ilosc,
        RANK() OVER (partition by przedmioty.nazwa ORDER BY  count(oceny.idoceny) desc) AS pozycja
FROM Oceny
JOIN Przedmioty
    ON Oceny.IdPrzedmiotu=Przedmioty.IdPrzedmiotu
WHERE Oceny.Ocena=2
GROUP BY  YEAR(Oceny.DataOceny),DATENAME(mm, Oceny.DataOceny),Przedmioty.Nazwa)

SELECT abc.rok,
        abc.miesiac,
        abc.Nazwa,
        abc.ilosc
FROM abc
WHERE pozycja =1