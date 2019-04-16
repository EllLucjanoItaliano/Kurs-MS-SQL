 ---podaj oceny studentow z kazdego przedmiotu
 SELECT Studenci.IdStudenta,
         Studenci.Nazwisko,
         Studenci.Imie,
         Studenci.DataUrodzenia,
        Oceny.Ocena,
         Przedmioty.Nazwa
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
ORDER BY  Nazwisko 

--- podaj oceny studentow urodzonych w roku 1986 i nalezacych do grupy 1
SELECT Studenci.IdStudenta,
         Studenci.Nazwisko,
         Studenci.Imie,
         Studenci.DataUrodzenia,
        Oceny.Ocena,
         Przedmioty.Nazwa
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
WHERE year(DataUrodzenia)=1986
        AND Studenci.IdGrupy=1
ORDER BY  Nazwisko 

--- podaj studentow urodzonych w 1986 roku, ktorzy nalezaa do grupy 1 i maja oceny
SELECT DISTINCT Studenci.IdStudenta,
         Studenci.Nazwisko,
         Studenci.Imie,
         Studenci.DataUrodzenia
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
WHERE year(DataUrodzenia)=1986
        AND Studenci.IdGrupy=1
ORDER BY  Nazwisko 

---podaj srednia wszystkich ocen
SELECT AVG(Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu 
    
---podaj srednia ocen dla kazdego studenta
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
         AVG(Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
GROUP BY  Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie 
        
---podaj srednia ocen dla kazdego studenta, z kazdego przedmiotu
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Przedmioty.Nazwa,
         AVG(Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
GROUP BY  Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
         Przedmioty.Nazwa 

---podaj srednia ocen dla kazdego studenta, z kazdego przedmiotu z podzialem na rok wystawienia
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Przedmioty.Nazwa,
        year(Oceny.DataOceny),
         AVG(Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie, Przedmioty.Nazwa, year(Oceny.DataOceny)
ORDER BY  YEAR(Oceny.DataOceny) 

---podaj ile ocen otrzymal kazdy student
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
         count(Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
GROUP BY Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie 
        
---podaj ktory student ma najwyzsza srednia
SELECT top 3 Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
         AVG(Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
ORDER BY  AVG(Ocena) desc