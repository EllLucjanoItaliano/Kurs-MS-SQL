--podaj średnią ocen studentów którzy opuścili najwięcej godzin (założenie, że jest jeden taki student)
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        avg(Oceny.Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE Studenci.IdStudenta IN 
    (SELECT top 1 Obecnosci.IdStudenta
    FROM Obecnosci
    WHERE Obecnosci.CzyBylObecny=0
    GROUP BY  Obecnosci.IdStudenta
    ORDER BY  count(Obecnosci.CzyBylObecny) DESC )
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
ORDER BY  AVG(Oceny.Ocena) desc

--podzapytanie
SELECT top 1 Obecnosci.IdStudenta
FROM Obecnosci
WHERE Obecnosci.CzyBylObecny=0
GROUP BY  Obecnosci.IdStudenta
ORDER BY  count(Obecnosci.CzyBylObecny) DESC 


--podaj średnią ocen studentów którzy opuścili najwięcej godzin (założenie, że może być kilku takich studentów)
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        avg(Oceny.Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE Studenci.IdStudenta IN ()
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
ORDER BY  AVG(Oceny.Ocena) desc


--podzapytanie - określamy najpierw jaka jest największa ilość godzin opuszczonych, 
SELECT top 1 count(Obecnosci.CzyBylObecny)
FROM Obecnosci
WHERE Obecnosci.CzyBylObecny=0
GROUP BY  Obecnosci.IdStudenta
ORDER BY  count(Obecnosci.CzyBylObecny) DESC 
--potem  sprawdzany id studentów, którzy opuścili taką ilość godzin
SELECT Obecnosci.IdStudenta
FROM Obecnosci
WHERE Obecnosci.CzyBylObecny=0
GROUP BY  Obecnosci.IdStudenta
HAVING count(Obecnosci.CzyBylObecny) = 
    (SELECT top 1 count(Obecnosci.CzyBylObecny)
    FROM Obecnosci
    WHERE Obecnosci.CzyBylObecny=0
    GROUP BY  Obecnosci.IdStudenta
    ORDER BY  count(Obecnosci.CzyBylObecny) DESC ) 

--podstawiamy podzapytanie złożone z 2 podzapytań do głównego pytania

SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        avg(Oceny.Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE Studenci.IdStudenta IN 
    (SELECT Obecnosci.IdStudenta
    FROM Obecnosci
    WHERE Obecnosci.CzyBylObecny=0
    GROUP BY  Obecnosci.IdStudenta
    HAVING count(Obecnosci.CzyBylObecny) = 
        (SELECT top 1 count(Obecnosci.CzyBylObecny)
        FROM Obecnosci
        WHERE Obecnosci.CzyBylObecny=0
        GROUP BY  Obecnosci.IdStudenta
        ORDER BY  count(Obecnosci.CzyBylObecny) DESC ))
    GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
ORDER BY  AVG(Oceny.Ocena) desc

---modyfikacja i sprawdzenie

SELECT top 3 Obecnosci.IdStudenta,
        count(Obecnosci.CzyBylObecny)
FROM Obecnosci
WHERE Obecnosci.CzyBylObecny=0
GROUP BY  Obecnosci.IdStudenta
ORDER BY  count(Obecnosci.CzyBylObecny) DESC --student 683 na 63 nieobecności, dodajemy mu dwie
SELECT *
FROM Obecnosci insert into Obecnosci (IdStudenta,IdPrzedmiotu,DataObecnosci,CzyBylObecny) values (683,4,'2016-01-01',0)




--podaj średnią ocen studentów którzy opuścili najmniej godzin (założenie, że może być kilku takich studentów) - najmniejsza liczba godzin opuszczonych lub ich brak

SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        avg(Oceny.Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE Studenci.IdStudenta IN 
    (SELECT Obecnosci.IdStudenta
    FROM Obecnosci
    WHERE Obecnosci.CzyBylObecny=0
    GROUP BY  Obecnosci.IdStudenta
    HAVING count(Obecnosci.CzyBylObecny) = 
        (SELECT top 1 count(Obecnosci.CzyBylObecny)
        FROM Obecnosci
        WHERE Obecnosci.CzyBylObecny=0
        GROUP BY  Obecnosci.IdStudenta
        ORDER BY  count(Obecnosci.CzyBylObecny) ))
    GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
ORDER BY  AVG(Oceny.Ocena) desc


--minimalna ilość nieobecności lub brak wpisów dla kontkretnego studenta w tabeli obecnosci
SELECT top 1 count(Obecnosci.CzyBylObecny)
FROM Obecnosci
RIGHT JOIN Studenci
    ON Studenci.IdStudenta=Obecnosci.IdStudenta
WHERE Obecnosci.CzyBylObecny=0
        OR Obecnosci.CzyBylObecny is null
GROUP BY  Studenci.IdStudenta
ORDER BY  count(Obecnosci.CzyBylObecny) 
--usunięcie wpisów w tabeli obecności dla studena o id =1
delete
FROM Obecnosci
WHERE Obecnosci.IdStudenta = 3

---w poniższym zapytaniu (w miejsce ....) wstawiamy podzapytanie  z wiersza 49
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        avg(Oceny.Ocena)
FROM Studenci
JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE Studenci.IdStudenta IN 
    (SELECT Obecnosci.IdStudenta
    FROM Obecnosci
    WHERE Obecnosci.CzyBylObecny=0
    GROUP BY  Obecnosci.IdStudenta
    HAVING count(Obecnosci.CzyBylObecny) = (...))
GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
ORDER BY  AVG(Oceny.Ocena) desc


--efekt końcowy: odaj średnią ocen studentów którzy opuścili najmniej godzin (założenie, że może być kilku takich studentów) - najmniejsza liczba godzin opuszczonych lub ich brak
SELECT Studenci.IdStudenta,
        Studenci.Nazwisko,
        Studenci.Imie,
        avg(Oceny.Ocena)
FROM Studenci
LEFT JOIN Oceny
    ON Studenci.IdStudenta=Oceny.IdStudenta
WHERE Studenci.IdStudenta IN 
    (SELECT Studenci.IdStudenta
    FROM Studenci
    LEFT JOIN Obecnosci
        ON Studenci.IdStudenta=Obecnosci.IdStudenta
    GROUP BY  Studenci.IdStudenta
    HAVING count(Obecnosci.CzyBylObecny) = 
        (SELECT top 1 count(Obecnosci.CzyBylObecny)
        FROM Obecnosci
        RIGHT JOIN Studenci
            ON Studenci.IdStudenta=Obecnosci.IdStudenta
        WHERE Obecnosci.CzyBylObecny=0
                OR Obecnosci.CzyBylObecny is null
        GROUP BY  Studenci.IdStudenta
        ORDER BY  count(Obecnosci.CzyBylObecny)))
    GROUP BY  Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie 


 --utworzenie tabe;i obecnosci
create table Obecnosci (
	IdObecnosci int not null identity(1,1) primary key,
	IdStudenta int not null,
	IdPrzedmiotu int not null,
	DataObecnosci date,
	CzyBylObecny bit
);
insert into Obecnosci (IdStudenta,IdPrzedmiotu,DataObecnosci,CzyBylObecny) 
values (1,1,'2019-01-26',1)

select * from Obecnosci
 