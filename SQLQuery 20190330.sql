/*funkcja szereguj�ca: 
RANK() -  zwraca pozycj� danego wiersza w rankingu
ROW_NUMBER() - zwraca kolejny numer wiersza wg okre�lonego porz�dku
DENSE_RANK() - zwraca pozycj� wiersza w rankingu w spos�b ci�g�y (je�eli dwa piersze pierwsze maj� t� sam� warto��, to trzeci wiersz na pozycj� nr 2
sk�adnia:
RANK() over (order by �rednia)
*/

-- podaj �redni� ocen poszczeg�lnych student�w oraz ich pozycj� w rankingu
use EP50_Uczelnia
select Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie,AVG(Oceny.Ocena) as srednia,
RANK() over (order by avg(oceny.ocena)) as PozRank,
Row_number() over (order by avg(oceny.ocena)) as PozRN,
DENSE_RANK() over (order by avg(oceny.ocena)) as PozDR
from Studenci join Oceny on Studenci.IdStudenta=Oceny.IdStudenta
group by Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
order by AVG(Oceny.Ocena)





---W bazie danych EP50_Przychodnia zrobi� ranking, wed�ug sumy op�at za wizyty zawieraj�cy nast�puj�ce dane; nazwisko, imi� i numer  ewidencyjny lekarza oraz sumaryczna kwot�  op�at za wizyty pe�noletnich kobiet z marca 2013. W rankingi nie uwzgl�dniamy  diabetolog�w i chirurg�w.W wyniku zestawienia powinni by� Ci lekarze, kt�rzy w rankingu zaj�li miejsca od 1 do 5.
use EP50_Przychodnia
select top 5 with ties Lekarze.Nazwisko,Lekarze.Imie,Lekarze.NrEwid,SUM(Wizyty.Oplata)
from Lekarze join Wizyty on Lekarze.IdLekarza=Wizyty.IdLekarza join Pacjenci on Pacjenci.IdPacjenta=Wizyty.IdPacjenta join Specjalizacje on Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji
where DATEDIFF(YY,Pacjenci.DataUrodzenia,Wizyty.DataWizyty)>17 and Pacjenci.CzyKobieta=1 and Wizyty.DataWizyty between '2013-03-01' and '2013-03-31' and Specjalizacje.NazwaSpecjalizacji not in ('Diabetolog','Chirurg')
group by Lekarze.Nazwisko,Lekarze.Imie,Lekarze.NrEwid
order by SUM(Wizyty.Oplata) desc

with RanWiz as (
select Lekarze.Nazwisko,Lekarze.Imie,Lekarze.NrEwid,SUM(Wizyty.Oplata) as SumaWplat,
RANK() over (order by SUM(Wizyty.Oplata) desc) as PozRank
from Lekarze join Wizyty on Lekarze.IdLekarza=Wizyty.IdLekarza join Pacjenci on Pacjenci.IdPacjenta=Wizyty.IdPacjenta join Specjalizacje on Specjalizacje.idspecjalizacji=Lekarze.Idspecjalizacji
where DATEDIFF(YY,Pacjenci.DataUrodzenia,Wizyty.DataWizyty)>17 and Pacjenci.CzyKobieta=1 and Wizyty.DataWizyty between '2013-03-01' and '2013-03-31' and Specjalizacje.NazwaSpecjalizacji not in ('Diabetolog','Chirurg') 
group by Lekarze.Nazwisko,Lekarze.Imie,Lekarze.NrEwid)
select * from RanWiz where PozRank<=5


--W bazie EP50_Hurtownia przygotowa� zestawienie zawieraj�ce nast�puj�ce dane nazwa firmy oraz numer Nip dla tych firm kt�re w roku 2012 wystawi�y wi�cej faktur ni� ich przyj�y.
use EP50_Hurtownia
select * from Faktury

with Wyst as(),
Kup as ()
select * from Wyst
intersect
select * from Kup



with Wystawione as 
(select Firmy.Nazwa,Firmy.Nip,COUNT(Faktury.IdFaktury) as IleWyst from Firmy join Faktury on Firmy.IdFirmy=Faktury.IdWystawcy
where year(Faktury.DataWystawienia)=2012
group by Firmy.Nazwa,Firmy.Nip),
Kupione as
(select Firmy.Nazwa,Firmy.Nip,COUNT(Faktury.IdFaktury) as IleKup from Firmy   join Faktury on Firmy.IdFirmy=Faktury.IdKupujacego
where year(Faktury.DataWystawienia)=2012
group by Firmy.Nazwa,Firmy.Nip)
select * from Wystawione join Kupione on wystawione.nip = kupione.nip
where IleWyst > IleKup




--W bazie danych EP50_przychodnia napisa�  zapytanie zwracaj�ce nast�puj�ce dane; nazw� miesi�ca, rok i sum� op�at za wizyty. Do oblicze� uwzgl�dniamy wizyty pacjent�w, kt�rzy w roku 2012 byli przynajmniej trzy razy u lekarza oraz tych lekarzy, kt�rzy w roku 2012 przyjmowali przynajmniej dw�ch pacjent�w starszych ni� 80 lat. Uwzgl�dniamy wizyty z roku 2012 i 2013.
use EP50_Przychodnia

With Pac3Razy as (
select Wizyty.IdPacjenta from Wizyty where year(Wizyty.DataWizyty)=2012 group by Wizyty.IdPacjenta having COUNT(Wizyty.IdWizyty) >=3
),Lekarze80 as (
select Wizyty.IdLekarza from Wizyty join Pacjenci on Pacjenci.IdPacjenta=Wizyty.IdPacjenta where YEAR(Wizyty.DataWizyty)=2012 and
DATEDIFF(YY,Pacjenci.DataUrodzenia,Wizyty.DataWizyty)>80 group by Wizyty.IdLekarza having COUNT(Wizyty.IdWizyty)>=2
)
select YEAR(Wizyty.DataWizyty) as rok,MONTH(Wizyty.DataWizyty) as miesiac,sum(Wizyty.Oplata) as SumaWplat
from Wizyty
where Wizyty.DataWizyty between '2012-01-01' and '2013-12-31' and Wizyty.IdPacjenta in (select IdPacjenta from Pac3Razy) and Wizyty.IdLekarza in (select IdLekarza from Lekarze80)
group by YEAR(Wizyty.DataWizyty),MONTH(Wizyty.DataWizyty)
order by YEAR(Wizyty.DataWizyty),MONTH(Wizyty.DataWizyty)

---W bazie danych EP50_Hurtownia napisa� zapytanie zwracaj�ce nast�puj�ce dane: nazw� firmy, numer nip oraz ilo�� wystawionych faktur w lutym 2012 dla tych firm, kt�re w lutym 2012 nie wystawi�y �adnej faktury firmie maj�cej siedzib� w Warszawie. W zestawieniu uwzgl�dniamy tylko te firmy, kt�re wystawi�y wi�cej ni� 10 faktur. Wynik uporz�dkowa� malej�co wed�ug ilo�ci wystawionych faktur.
use EP50_Hurtownia

with FirmyWarsz as (
select Firmy.IdFirmy from Firmy where Firmy.IdMiasta=7
)
select Firmy.Nazwa,Firmy.Nip,COUNT(Faktury.IdFaktury)
from Firmy join Faktury on Firmy.IdFirmy=Faktury.IdWystawcy
where Faktury.DataWystawienia between '2012-02-01' and '2012-02-29' and Faktury.IdKupujacego not in (select IdFirmy from FirmyWarsz)
group by Firmy.Nazwa,Firmy.Nip
having COUNT(Faktury.IdFaktury) >10
order by COUNT(Faktury.IdFaktury) desc



---W bazie danych EP50_Hurtownia napisa� zapytanie zwracaj�ce nast�puj�ce dane: nazw� firmy, numer nip oraz ilo�� wystawionych faktur w lutym 2012 dla tych firm, kt�re w lutym 2012 nie wystawi�y �adnej faktury firmie maj�cej siedzib� w Warszawie. W zestawieniu uwzgl�dniamy tylko te firmy, kt�re wystawi�y wi�cej ni� 10 faktur. Wynik uporz�dkowa� malej�co wed�ug ilo�ci wystawionych faktur. Podaj firmy, kt�re zajmuj� pozycje: 2,4,6 w tym rankingu
use EP50_Hurtownia

with FirmyWarsz as (
select Firmy.IdFirmy from Firmy where Firmy.IdMiasta=7
)
 
select Firmy.Nazwa,Firmy.Nip,COUNT(Faktury.IdFaktury) as ilosc,RANK() over (order by COUNT(Faktury.IdFaktury) desc) as pozycja
from Firmy join Faktury on Firmy.IdFirmy=Faktury.IdWystawcy
where Faktury.DataWystawienia between '2012-02-01' and '2012-02-29' and Faktury.IdKupujacego not in (select IdFirmy from FirmyWarsz)
group by Firmy.Nazwa,Firmy.Nip
having COUNT(Faktury.IdFaktury) >10
order by COUNT(Faktury.IdFaktury) desc



---W bazie danych EP50_Uczelnia napisa� zapytanie, kt�re zwraca nast�puj�ce dane: nazwisko, imi� i Pesel student�w oraz �redni� ocen� z ocen wystawionych przez wyk�adowc�, kt�ry w roku 2013 osi�gn�� najwi�kszy przyrost warto�ci �redniej wystawionych ocen z jednego przedmiotu w por�wnaniu z rokiem 2012. W wyniku uwzgl�dniamy tylko tych student�w, kt�ry u danego wyk�adowcy otrzymali wi�cej ni� 4 oceny. Wynik uporz�dkowa� malej�co wed�ug �redniej.
use EP50_Uczelnia
with oceny2012 as (
select Oceny.IdWykladowcy,Oceny.IdPrzedmiotu,avg(Oceny.Ocena) as sr2012
from Oceny where YEAR(Oceny.DataOceny)=2012 group by Oceny.IdWykladowcy,Oceny.IdPrzedmiotu 
),
oceny2013 as (
select Oceny.IdWykladowcy,Oceny.IdPrzedmiotu,avg(Oceny.Ocena) as sr2013
from Oceny where YEAR(Oceny.DataOceny)=2013 group by Oceny.IdWykladowcy,Oceny.IdPrzedmiotu 
),
WyklWzrost as (select top 1 with ties
Oceny2013.idWykladowcy,Oceny2013.idprzedmiotu,sr2013-sr2012 as roznica
from oceny2013 join oceny2012 on oceny2012.idwykladowcy = oceny2013.idwykladowcy  order by roznica desc
)
select Studenci.Nazwisko,Studenci.Imie,Studenci.Pesel, AVG(Oceny.Ocena) from Studenci join Oceny on Studenci.IdStudenta=Oceny.IdStudenta
where Oceny.IdWykladowcy in (select IdWykladowcy from WyklWzrost)
group by Studenci.Nazwisko,Studenci.Imie,Studenci.Pesel
having COUNT(Oceny.IdOceny)>4
order by AVG(Oceny.Ocena) desc


--W bazie danych EP50_Przychodnia przygotowa� zestawienie zawieraj�ce nast�puj�ce dane; nazwisko, imi�  i Pesel pacjenta oraz ilo�� wizyt danego pacjenta w II p�roczu 2013. W wyniku uwzgl�dni� tylko tych pacjent�w, kt�rzy byli  przynajmniej 5 razy u lekarza. Wynik zapytania uporz�dkowa� malej�co wed�ug ilo�ci wizyt
use EP50_Przychodnia
SELECT P.Nazwisko as NazwiskoPacjenta, 
       P.Imie as ImiePacjenta,
       P.Pesel as PeselPacjenta,
       COUNT(*) as IleWizyt
FROM Pacjenci as P JOIN Wizyty as W ON P.IdPacjenta=W.IdPacjenta  
                                JOIN Lekarze as L on W.IdLekarza=L.IdLekarza
WHERE dataWizyty BETWEEN '20130701' AND '20131231'
GROUP BY P.Nazwisko,P. Imie,P.Pesel
HAVING COUNT(*)> 4
ORDER BY IleWizyt DESC


---tworzenie tabel
create table Tabela1 (
idTabeli int not null identity(1,1) primary key,
Nazwa varchar(30),
Uwagi varchar(50),
DataZdarzenia date 
)

select * from Tabela1

insert into Tabela1 (Nazwa,Uwagi,DataZdarzenia) values ('nazwa jaka�','brak uwagi','2018-01-02')
select * from Tabela1

---dadanie komuny do tabeli 
alter table tabela1 add DodanaKolumna varchar(80)

--usuwanie kolumn z tabeli
alter table tabela1 drop column dodanakolumna

--tworzenie tabeli (wg struktury innej tabeli) i kopiowanie danych do tej tabeli z innej tabeli
--tworznie kopii tabeli oceny
select * into OcenyKopia2012 from Oceny where year(DataOCeny)=2012
select * into OcenyKopia2013 from Oceny where year(DataOCeny)=2013
select * into OcenyKopia2014 from Oceny where year(DataOCeny)=2014
select * from OcenyKopia2012 

---kopiowanie rekord�w do istniej�cej tabeli
delete from OcenyKopia2012
insert into OcenyKopia2012 select idStudenta,IdWykladowcy,idprzedmiotu,idrodzajuoceny,dataoceny,ocena from Oceny where year(DataOCeny)=2012

--TRANSAKCJE
begin transaction;
instrukcja1;
instrukcja2;
instrukcja3;
commit (zatwierdza wykonanie); lub rollback (wycofuje transakcj� );


use EP50_Przychodnia
-- utw�rz archiwum wizyt z roku 2012
begin transaction;
select * into Wizyty2012 from Wizyty where YEAR(Wizyty.DataWizyty)=2012;
delete from Wizyty where YEAR(Wizyty.DataWizyty)=2012
commit;

select * from Pacjenci
---podzia� tabeli Pacjenci na dwie tabele (jedna z tabel zawiera dane tzw. "wra�liwe")
begin transaction;
select IdPacjenta,Pesel,DataUrodzenia into PacjenciRodo from Pacjenci;
alter table Pacjenci drop column Pesel;
alter table Pacjenci drop column DataUrodzenia; 
commit;

select * from PacjenciRodo

---przychodnia przesz�� reorganizacj�. Internista i pediatra za�o�yli w�asn� odr�bn� przychodni�. Nale�y przenie�� dane lekarzy internist�w i pediatr�w do innych tabel. Dodatkowo nale�y przenie�� wizyty tych lekarzy do innych tabel. Nazwy nowych tabel: Lekarze2 oraz Wizyty2

begin transaction;
select * into Lekarze2 from Lekarze where Lekarze.Idspecjalizacji in (2,3); 
select * into Wizyty2 from Wizyty where Wizyty.IdLekarza in (select Lekarze.IdLekarza from Lekarze where Lekarze.Idspecjalizacji in (2,3));
delete from Lekarze where Lekarze.Idspecjalizacji in (2,3); 
delete from Wizyty where Wizyty.IdLekarza in (select Lekarze.IdLekarza from Lekarze where Lekarze.Idspecjalizacji in (2,3));
commit;

select * from Lekarze2


---w tabeli pacjenci kobietom ustaw pole CzyKobieta na 0, a m�czyznom na 1
---zmiana warto�ci pola w tabeli
update Lekarze set Idspecjalizacji=1 where Lekarze.CzyKobieta=1
select * from Lekarze

alter table lekarze alter column czykobieta bit not null
select * from Lekarze

begin transaction;
alter table lekarze alter column czykobieta int
update Lekarze set CzyKobieta=2 where CzyKobieta=1
update Lekarze set CzyKobieta=1 where CzyKobieta=0
update Lekarze set CzyKobieta=0 where CzyKobieta=2
alter table lekarze alter column czykobieta bit not null
commit;

select * from Lekarze