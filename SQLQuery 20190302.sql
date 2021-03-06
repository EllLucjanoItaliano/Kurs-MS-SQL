---podaj �redni� ocen wszystkich student�w, wynik posortuj malej�co wg �redniej
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
         iif(Studenci.CzyKobieta=1,
        'Kobieta','M�czyzna'), AVG(Oceny.Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie,Studenci.CzyKobieta
ORDER BY  AVG(oceny.ocena) desc;

---podaj �redni� ocen dla 20 najlepszych student�w, wynik posortuj malej�co wg �redniej
SELECT top 20
WITH ties Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie, iif(Studenci.CzyKobieta=1,'Kobieta','M�czyzna'), AVG(Oceny.Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie,Studenci.CzyKobieta
ORDER BY  AVG(oceny.ocena) desc;

---podaj �redni� ocen dla drugiej 10 najlepszych student�w, wynik posortuj malej�co wg �redniej
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
         iif(Studenci.CzyKobieta=1,
        'Kobieta','M�czyzna'), AVG(Oceny.Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie,Studenci.CzyKobieta
ORDER BY  AVG(oceny.ocena) DESC offset 10 rows fetch next 10 rows only


---po��czenie zapyta� UNION (suma zapyta�) ,INTERSECT (cze�� wsp�lna) ,EXCEPT (rekordy nale��ce do pierwszego, a nie nale��ce do drugiego zapytania)

SELECT *
FROM GrupySzkoleniowe
WHERE Nazwa LIKE 'INF%'

--podaj student�w, kt�rzy nale�� do grup szkoleniowych informatycznych i matematycznych

SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie
FROM Studenci
JOIN GrupySzkoleniowe
    ON Studenci.IdGrupy=GrupySzkoleniowe.IdGrupy
WHERE GrupySzkoleniowe.Nazwa LIKE 'INF%'
UNION
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie
FROM Studenci
JOIN GrupySzkoleniowe
    ON Studenci.IdGrupy=GrupySzkoleniowe.IdGrupy
WHERE GrupySzkoleniowe.Nazwa LIKE 'MAT%'

---podaj student�w, kt�rzy maj� �reni� 4 i wy�ej, a nie opu�cili wi�cej ni� 30 godzin
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
HAVING AVG(Oceny.Ocena) >=3.5 INTERSECTSELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie
FROM Studenci
JOIN Obecnosci
    ON Studenci.IdStudenta=Obecnosci.IdStudenta
WHERE Obecnosci.CzyBylObecny =0
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
HAVING COUNT(Obecnosci.CzyBylObecny) <=30 
--zmiana na obecno�� wszystkich rekord�w dla student�w o id od 20 do 50
update Obecnosci set CzyBylObecny =1 where IdStudenta between 20 and 500


---podaj student�w, kt�rzy maj� �reni� 4 i wy�ej, a nie opu�cili wi�cej ni� 30 godzin (wersja 2)
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE Studenci.IdStudenta IN 
    (SELECT Studenci.IdStudenta
    FROM Studenci
    JOIN Obecnosci
        ON Studenci.IdStudenta=Obecnosci.IdStudenta
    WHERE Obecnosci.CzyBylObecny =0
    GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
    HAVING COUNT(Obecnosci.CzyBylObecny) <=30)
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
HAVING AVG(Oceny.Ocena) >=3.5

--z jakich przedmit�w poszczeg�lni studenci maj� oceny
SELECT DISTINCT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Przedmioty.Nazwa
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
ORDER BY  Studenci.IdStudenta,Przedmioty.Nazwa 
--z jakich przedmiot�w powinii mie� oceny poszczeg�lni studenci

SELECT DISTINCT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Przedmioty.Nazwa
FROM Studenci
CROSS JOIN Przedmioty 

--z jakich przedmiot�w poszczeg�lni studenci nie maj� ocen

SELECT DISTINCT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Przedmioty.Nazwa
FROM Studenci
CROSS JOIN Przedmioty EXCEPT SELECT DISTINCT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Przedmioty.Nazwa
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
ORDER BY  Studenci.IdStudenta,Przedmioty.Nazwa


--z jakich przedmiot�w powinii mie� oceny poszczeg�lni studenci (z widokiem)
create view PowinniMiecOceny AS
SELECT DISTINCT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Przedmioty.Nazwa
FROM Studenci
CROSS JOIN Przedmioty 

select * from PowinniMiecOceny

--z jakich przedmit�w poszczeg�lni studenci maj� oceny (z widokiem)
create view MajaOceny as
SELECT DISTINCT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Przedmioty.Nazwa
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu

--z jakich przedmiot�w poszczeg�lni studenci nie maj� ocen
select * from PowinniMiecOceny except select * from MajaOceny

---utw�rz widok kt�rzy zawiera dane student�w ��cznie z nazwami grup oraz nazwami kireunk�w studi�w
create view StudenciPelneDane as 
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        KierunkiStudiow.NazwaKierunku,
        GrupySzkoleniowe.Nazwa AS NazwaGrupy
FROM Studenci
JOIN GrupySzkoleniowe
    ON Studenci.IdGrupy=GrupySzkoleniowe.IdGrupy
JOIN KierunkiStudiow
    ON GrupySzkoleniowe.IdKierunkuStudiow=KierunkiStudiow.IdKierunkuStudiow

select * from StudenciPelneDane

---utw�rz widok z danymi student�w i ich �redni� ocen
create view StudenciSrednia ASSELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        AVG(Oceny.Ocena) AS srednia
FROM Studenci
LEFT JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie

---podaj osoby ze �redni� 4 i wy�ej
SELECT *
FROM StudenciSrednia
WHERE srednia >=4

---inicja�y student�w
SELECT left(Studenci.Nazwisko,1)+'.'+left(Studenci.imie,1)+'.' AS inicjaly
FROM Studenci

--podanie systemowej
select getdate()

--zamiana sposobu wy�wietlania daty systemowej
 select CONVERT (date, getdate()) 

 
--obliczanie wieku student�w  
SELECT DATEDIFF(yy,Studenci.DataUrodzenia,getdate()) AS wiek
FROM Studenci

create view StudenciWiek as
SELECT StudenciPelneDane.IdStudenta,
        StudenciPelneDane.Nazwisko,
        StudenciPelneDane.Imie,
        StudenciPelneDane.NazwaGrupy,
        StudenciPelneDane.NazwaKierunku,
        DATEDIFF(yy,Studenci.DataUrodzenia,getdate()) AS wiek
FROM StudenciPelneDane
JOIN Studenci
    ON StudenciPelneDane.IdStudenta=Studenci.IdStudenta

---podaj student�w urodzonych w maju
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Studenci.DataUrodzenia
FROM Studenci
WHERE month (Studenci.DataUrodzenia) = '05'


---zamie� wszystkie oceny z baz danych na 6 studentom, kt�rzy maj� �redni� ocen 4.1 i powy�ej 

UPDATE Oceny SET Ocena=6
WHERE Oceny.IdPrzedmiotu = 
    (SELECT Przedmioty.IdPrzedmiotu
    FROM Przedmioty
    WHERE Przedmioty.Nazwa ='bazy danych')
        AND Oceny.IdStudenta IN 
    (SELECT StudenciSrednia.IdStudenta
    FROM StudenciSrednia
    WHERE StudenciSrednia.srednia >=4.1)


---szukamy osoby, kt�ra ma �redni� ocen powy�ej 4.1 a nie ma ocen z baz danych

--najpierw szukamy studen�w kt�rzy nie maj� ocen z baz danych
SELECT StudenciSrednia.IdStudenta
FROM StudenciSrednia
WHERE StudenciSrednia.srednia >=4.1
EXCEPT
SELECT StudenciBezOcen.IdStudenta
FROM StudenciBezOcen 


---dostawiamy 6 z bad danych studentowi, kt�ry nie mia� oceny za bad dabych, a ma �redni� ocen min.4.1

insert into Oceny (IdStudenta,IdWykladowcy,IdPrzedmiotu,IdRodzajuOceny,DataOceny,Ocena) values (647,30,2,3,'2019-03-02',6)

select top 1 * from Oceny order by Oceny.IdOceny desc


use EP50_Przychodnia
--utw�rz widok, kt�ry zawiera� dane o pacjentach,lekarzach i wizycie
create view WizytyPelneDane AS
SELECT Pacjenci.IdPacjenta,
        Pacjenci.Nazwisko,
        Pacjenci.Imie,
        Pacjenci.Pesel,
        Pacjenci.DataUrodzenia,
         IIF(Pacjenci.CzyKobieta=1,'Kobieta','M�czyzna') AS plec,
          Lekarze.Nazwisko AS NazwiskoLekarza,
          Lekarze.Imie AS ImieLekarza,
          Specjalizacje.NazwaSpecjalizacji,
          Wizyty.Oplata
FROM Pacjenci
JOIN Wizyty
    ON Pacjenci.IdPacjenta=Wizyty.IdPacjenta
JOIN Lekarze
    ON Lekarze.IdLekarza=Wizyty.IdLekarza
JOIN Specjalizacje
    ON Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji

select * from WizytyPelneDane

--- kt�re wizyty (specjalizacja) �rednio s� najdro�sze
SELECT WizytyPelneDane.NazwaSpecjalizacji,
        AVG(WizytyPelneDane.Oplata)
FROM WizytyPelneDane
GROUP BY  WizytyPelneDane.NazwaSpecjalizacji
ORDER BY  AVG(WizytyPelneDane.Oplata) DESC 

--podaj sum� op�at za wizyt� dla poszczeg�lnych lekarzy
SELECT WizytyPelneDane.NazwiskoLekarza,
        WizytyPelneDane.ImieLekarza,
        WizytyPelneDane.NazwaSpecjalizacji,
        sum(WizytyPelneDane.Oplata)
FROM WizytyPelneDane
GROUP BY  WizytyPelneDane.NazwiskoLekarza,WizytyPelneDane.ImieLekarza,WizytyPelneDane.NazwaSpecjalizacji
ORDER BY  sum(WizytyPelneDane.Oplata) DESC 

--podaj sum� op�at za wizyty dla poszczeg�lnych lekarzy od pacjentek, kt�re maj� powy�ej 40 lat
SELECT WizytyPelneDane.NazwiskoLekarza,
        WizytyPelneDane.ImieLekarza,
        WizytyPelneDane.NazwaSpecjalizacji,
         sum(WizytyPelneDane.Oplata)
FROM WizytyPelneDane
WHERE plec='Kobieta'
        AND DATEDIFF(yy,WizytyPelneDane.DataUrodzenia,GETDATE()) >40
GROUP BY  WizytyPelneDane.NazwiskoLekarza,WizytyPelneDane.ImieLekarza,WizytyPelneDane.NazwaSpecjalizacji
ORDER BY  sum(WizytyPelneDane.Oplata) desc 

--podaj sum� op�at za wizyty dla poszczeg�lnych lekarzy (opr��z internisty i lekrza rodzinnego) od pacjentek, kt�re maj� powy�ej 40 lat
SELECT WizytyPelneDane.NazwiskoLekarza,
        WizytyPelneDane.ImieLekarza,
        WizytyPelneDane.NazwaSpecjalizacji,
         sum(WizytyPelneDane.Oplata)
FROM WizytyPelneDane
WHERE plec='Kobieta'
        AND DATEDIFF(yy,WizytyPelneDane.DataUrodzenia,GETDATE()) >40
        AND WizytyPelneDane.NazwaSpecjalizacji NOT IN ('Internista','Lekarz rodzinny')
GROUP BY  WizytyPelneDane.NazwiskoLekarza,WizytyPelneDane.ImieLekarza,WizytyPelneDane.NazwaSpecjalizacji
ORDER BY  sum(WizytyPelneDane.Oplata) DESC 

