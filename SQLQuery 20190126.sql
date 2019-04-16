/* policz �reni� ocen student�w z grupy 2 oraz wska� student�w, kt�rzy maj� najwy�sz� �redni� 
(najpierw okre�lamy jaka to jest najwy�sza �rednia, a potem kto ma tak� �redni�*/
SELECT top 2 s.IdStudenta,
        s.Nazwisko,
        s.Imie,
        avg(o.Ocena)
FROM Studenci AS s
JOIN Oceny AS o
    ON s.IdStudenta=o.IdStudenta
WHERE s.IdGrupy=2
GROUP BY  s.IdStudenta,s.Nazwisko,s.Imie
HAVING avg(o.Ocena)>= 3.5
ORDER BY  avg(o.Ocena) desc

--jak jest najwy�sza �rednia
SELECT top 1 AVG(ocena)
FROM Oceny
JOIN Studenci
    ON Oceny.IdStudenta=Studenci.IdStudenta
WHERE Studenci.IdGrupy=2
GROUP BY  Studenci.IdStudenta
ORDER BY  AVG(ocena) desc
--poka� student�w, kt�rzy maj� tak� jak powy�ej �redni�
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        AVG(Oceny.Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
HAVING avg(ocena) = 
    (SELECT top 1 AVG(ocena)
    FROM Oceny
    JOIN Studenci
        ON Oceny.IdStudenta=Studenci.IdStudenta
    WHERE Studenci.IdGrupy=2
    GROUP BY  Studenci.IdStudenta
    ORDER BY  AVG(ocena) desc)UPDATE Oceny SET Ocena =4
WHERE IdStudenta=44


-- z jakich przedmiot�w studenci powinni mie� oceny
SELECT DISTINCT studenci.IdStudenta,
        Oceny.IdPrzedmiotu
FROM Studenci
CROSS JOIN Oceny
ORDER BY  Studenci.IdStudenta,Oceny.IdPrzedmiotu

---poka� kto ma oceny
SELECT Studenci.IdStudenta,
        Oceny.Ocena
FROM Studenci
LEFT JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
ORDER BY  Studenci.IdStudenta

---poka� kto nie ma ocen
SELECT Studenci.IdStudenta,
        Oceny.Ocena
FROM Studenci
LEFT JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE Oceny.Ocena is null
ORDER BY  Studenci.IdStudenta

--poka� wyk�adowc�w, kt�rzy nie wystawili jeszcze oceny
SELECT Wykladowcy.IdWykladowcy,
        Wykladowcy.Nazwisko,
        Wykladowcy.Imie,
        Oceny.Ocena
FROM Oceny
RIGHT JOIN Wykladowcy
    ON Wykladowcy.IdWykladowcy=Oceny.IdWykladowcy
WHERE Oceny.Ocena is null

/*---poka�, kt�rzy studenci (samo Id) maj� takie samo nazwisko jak wyk�adowca (zapytanie wykorzystuje 
tabel� oceny - b�edny wynik, gdy student nie ma ocen*/
SELECT DISTINCT studenci.IdStudenta
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta =Oceny.IdStudenta
JOIN Wykladowcy
    ON Wykladowcy.IdWykladowcy=Oceny.IdWykladowcy
WHERE Studenci.Nazwisko IN 
    (SELECT Wykladowcy.Nazwisko
    FROM Wykladowcy)
SELECT *
FROM Wykladowcy
ORDER BY  NazwiskoSELECT *
FROM Studenci
ORDER BY  Studenci.idstudentaUPDATE Studenci SET Nazwisko='Kotowicz'
WHERE Studenci.IdStudenta
    BETWEEN 231
        AND 235 delete
FROM oceny
WHERE IdStudenta
    BETWEEN 231
        AND 235


/*---poka�, kt�rzy studenci (samo Id) maj� takie samo nazwisko jak wyk�adowca (zapytanie 
nie wykorzystuje tabeli oceny - prawid�owy wynik, nawt gdy student nie ma ocen*/
SELECT DISTINCT studenci.IdStudenta
FROM Studenci
WHERE Studenci.Nazwisko IN 
    (SELECT Wykladowcy.Nazwisko
    FROM Wykladowcy)

/*---poka� oceny z przedmiotu bazy danych student�w z grupy 3, kt�rzy maj� �redni� ocen powy�ej 3.5
podzapytanie zwraca informacj� kt�rzy studenci maj� �redni� powy�ej 3.5
*/
SELECT Oceny.IdStudenta
FROM Oceny
GROUP BY  Oceny.IdStudenta
HAVING AVG(Oceny.Ocena)>3.5SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Przedmioty.Nazwa,
        Oceny.Ocena
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
WHERE Studenci.IdGrupy=3
        AND Przedmioty.Nazwa='bazy danych'
        AND Studenci.IdStudenta IN 
    (SELECT Oceny.IdStudenta
    FROM Oceny
    GROUP BY  Oceny.IdStudenta
    HAVING AVG(Oceny.Ocena)>3.5)



/*---poka� oceny z przedmiotu bazy danych student�w z grupy 3, kt�rzy maj� �redni� ocen powy�ej 3.5
podzapytanie zwraca informacj� kt�rzy studenci Z GRUPY 3 MAJ� �redni� powy�ej 3.5
*/
SELECT Oceny.IdStudenta
FROM Oceny
JOIN Studenci
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE Studenci.IdGrupy=3
GROUP BY  Oceny.IdStudenta
HAVING AVG(Oceny.Ocena)>3.5SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Przedmioty.Nazwa,
        Oceny.Ocena
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
WHERE Przedmioty.Nazwa='bazy danych'
        AND Studenci.IdStudenta IN 
    (SELECT Oceny.IdStudenta
    FROM Oceny
    JOIN Studenci
        ON Studenci.IdStudenta=Oceny.IdStudenta
    WHERE Studenci.IdGrupy=3
    GROUP BY  Oceny.IdStudenta
    HAVING AVG(Oceny.Ocena)>3.5)

/*ustaw oceny z baz danych na 5 dla wszystkich student�w z grupy 3, 
kt�rzy maj� �redni� ocen powy�ej 3.5*/
UPDATE Oceny SET Ocena=5
WHERE IdStudenta in
    (SELECT Oceny.IdStudenta
    FROM Oceny
    JOIN Studenci
        ON Studenci.IdStudenta=Oceny.IdStudenta
    WHERE Studenci.IdGrupy=3
    GROUP BY  Oceny.IdStudenta
    HAVING AVG(Oceny.Ocena)>3.5) 

--- sprawdzenie czy oceny zosta�y zmienione tylko u niket�rych student�w
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        Przedmioty.Nazwa,
        Oceny.Ocena
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
JOIN Przedmioty
    ON Przedmioty.IdPrzedmiotu=Oceny.IdPrzedmiotu
WHERE Przedmioty.Nazwa='bazy danych'
        AND Studenci.IdStudenta IN 
    (SELECT Oceny.IdStudenta
    FROM Oceny
    JOIN Studenci
        ON Studenci.IdStudenta=Oceny.IdStudenta
    WHERE Studenci.IdGrupy=3
    GROUP BY  Oceny.IdStudenta
    HAVING AVG(Oceny.Ocena)>1)



--- pokadaj �redni� ocen wystwionych przez wyk�adowc�w, kt�rzy urodzili si� w latach 1975-1990
--podzapytanie
select Wykladowcy.IdWykladowcy from Wykladowcy where YEAR(Wykladowcy.DataUrodzenia) 
between 1975 and 1990



