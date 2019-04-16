---podaj �redni� ocen student�w urodzonych w 1990, dla student�w dla kt�rych ta �rednia jest wy�sza ni� 3.8
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Studenci.DataUrodzenia,
        avg(Oceny.Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE YEAR(Studenci.DataUrodzenia) = 1990
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie,Studenci.DataUrodzenia
HAVING avg(Oceny.Ocena) >=3.8
ORDER BY  avg(Oceny.Ocena) desc;


---podaj �redni� ocen student�w urodzonych w 1990, kt�rych ilo�� nieobecno�ci jest mniejsza ni� 35
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Studenci.DataUrodzenia,
        avg(Oceny.Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE YEAR(Studenci.DataUrodzenia) = 1990
        AND Studenci.IdStudenta IN 
    (SELECT Obecnosci.IdStudenta
    FROM Obecnosci
    WHERE CzyBylObecny=0
    GROUP BY  Obecnosci.IdStudenta
    HAVING COUNT(Obecnosci.DataObecnosci)<35)
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie,Studenci.DataUrodzenia
ORDER BY  avg(Oceny.Ocena) desc;

SELECT Obecnosci.IdStudenta
FROM Obecnosci
WHERE CzyBylObecny=0
GROUP BY  Obecnosci.IdStudenta
HAVING COUNT(Obecnosci.DataObecnosci)<35SELECT *
FROM Obecnosci 


--podaj �redni koszt wizyty kobiet urodzonych w 2010 roku do internisty
SELECT Pacjenci.Nazwisko,
        Pacjenci.Imie,
        year(Pacjenci.DataUrodzenia),
        Specjalizacje.NazwaSpecjalizacji,
        sum(Wizyty.Oplata) AS srednia_oplata
FROM Pacjenci
JOIN Wizyty
    ON Pacjenci.IdPacjenta=Wizyty.IdPacjenta
JOIN Lekarze
    ON Wizyty.IdLekarza=Lekarze.IdLekarza
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
WHERE Pacjenci.CzyKobieta=1
        AND YEAR(Pacjenci.DataUrodzenia)=2010
        AND Specjalizacje.NazwaSpecjalizacji='pediatra'
GROUP BY  Pacjenci.Nazwisko,Pacjenci.Imie,year(Pacjenci.DataUrodzenia),Specjalizacje.NazwaSpecjalizacji
ORDER BY  sum(Wizyty.Oplata) desc



--podaj �redni koszt wizyty kobiet urodzonych w 2010 roku do internisty (podzapytnie)
SELECT Pacjenci.Nazwisko,
        Pacjenci.Imie,
        year(Pacjenci.DataUrodzenia),
         sum(Wizyty.Oplata) AS srednia_oplata
FROM Pacjenci
JOIN Wizyty
    ON Pacjenci.IdPacjenta=Wizyty.IdPacjenta
WHERE Pacjenci.CzyKobieta=1
        AND YEAR(Pacjenci.DataUrodzenia)=2010
        AND Wizyty.IdLekarza IN 
    (SELECT Lekarze.IdLekarza
    FROM Lekarze
    JOIN Specjalizacje
        ON Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji
    WHERE Specjalizacje.NazwaSpecjalizacji='pediatra')
GROUP BY  Pacjenci.Nazwisko,Pacjenci.Imie,year(Pacjenci.DataUrodzenia)
ORDER BY  sum(Wizyty.Oplata) DESC 




---w bazie danych EP50_przychodnia napisz zapytanie, kt�re zwr�ci nast�puj�ce dane: naziwsko,imie, i rok urodzenia tych pacjentek, kt�re w roku 2012 by�y przyjmniej 5 razy u pediatry
SELECT Pacjenci.Nazwisko,
        Pacjenci.Imie,
        YEAR(Pacjenci.DataUrodzenia)
FROM Pacjenci
WHERE Pacjenci.CzyKobieta=1
        AND Pacjenci.IdPacjenta IN 
    (SELECT Wizyty.IdPacjenta
    FROM Wizyty
    JOIN Lekarze
        ON Wizyty.IdLekarza=Lekarze.IdLekarza
    JOIN Specjalizacje
        ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
    WHERE YEAR(Wizyty.DataWizyty)=2012
            AND Specjalizacje.NazwaSpecjalizacji='pediatra'
    GROUP BY  Wizyty.IdPacjenta
    HAVING COUNT(Wizyty.Oplata)>4)

--podzapytanie
SELECT Wizyty.IdPacjenta
FROM Wizyty
JOIN Lekarze
    ON Wizyty.IdLekarza=Lekarze.IdLekarza
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
WHERE YEAR(Wizyty.DataWizyty)=2012
        AND Specjalizacje.NazwaSpecjalizacji='pediatra'
GROUP BY  Wizyty.IdPacjenta
HAVING COUNT(Wizyty.Oplata)>4


---w bazie EP50_Przychodnia napisa� zapytanie, kt�re przygotuje nast�puj�ce dane: nazwisko,imi� i nazw� specjalizacji tych lekarzy, kt�rzy w roku 2013 nie przyjmowali �adnej kobiety
SELECT Lekarze.Nazwisko,
        Lekarze.Imie,
        Specjalizacje.NazwaSpecjalizacji
FROM Lekarze
JOIN Specjalizacje
    ON Lekarze.Idspecjalizacji=Specjalizacje.idspecjalizacji
WHERE Lekarze.IdLekarza IN ()








