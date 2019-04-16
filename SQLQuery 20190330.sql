/*funkcja szereguj¹ca: 
RANK() -  zwraca pozycjê danego wiersza w rankingu
ROW_NUMBER() - zwraca kolejny numer wiersza wg okreœlonego porz¹dku
DENSE_RANK() - zwraca pozycjê wiersza w rankingu w sposób ci¹g³y (je¿eli dwa piersze pierwsze maj¹ tê sam¹ wartoœæ, to trzeci wiersz na pozycjê nr 2
sk³adnia:
RANK() over (order by œrednia)
*/

-- podaj œredni¹ ocen poszczególnych studentów oraz ich pozycjê w rankingu
use EP50_Uczelnia
select Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie,AVG(Oceny.Ocena) as srednia,
RANK() over (order by avg(oceny.ocena)) as PozRank,
Row_number() over (order by avg(oceny.ocena)) as PozRN,
DENSE_RANK() over (order by avg(oceny.ocena)) as PozDR
from Studenci join Oceny on Studenci.IdStudenta=Oceny.IdStudenta
group by Studenci.IdStudenta,Studenci.Nazwisko,Studenci.Imie
order by AVG(Oceny.Ocena)





---W bazie danych EP50_Przychodnia zrobiæ ranking, wed³ug sumy op³at za wizyty zawieraj¹cy nastêpuj¹ce dane; nazwisko, imiê i numer  ewidencyjny lekarza oraz sumaryczna kwotê  op³at za wizyty pe³noletnich kobiet z marca 2013. W rankingi nie uwzglêdniamy  diabetologów i chirurgów.W wyniku zestawienia powinni byæ Ci lekarze, którzy w rankingu zajêli miejsca od 1 do 5.
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


--W bazie EP50_Hurtownia przygotowaæ zestawienie zawieraj¹ce nastêpuj¹ce dane nazwa firmy oraz numer Nip dla tych firm które w roku 2012 wystawi³y wiêcej faktur ni¿ ich przyjê³y.
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




--W bazie danych EP50_przychodnia napisaæ  zapytanie zwracaj¹ce nastêpuj¹ce dane; nazwê miesi¹ca, rok i sumê op³at za wizyty. Do obliczeñ uwzglêdniamy wizyty pacjentów, którzy w roku 2012 byli przynajmniej trzy razy u lekarza oraz tych lekarzy, którzy w roku 2012 przyjmowali przynajmniej dwóch pacjentów starszych ni¿ 80 lat. Uwzglêdniamy wizyty z roku 2012 i 2013.
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

---W bazie danych EP50_Hurtownia napisaæ zapytanie zwracaj¹ce nastêpuj¹ce dane: nazwê firmy, numer nip oraz iloœæ wystawionych faktur w lutym 2012 dla tych firm, które w lutym 2012 nie wystawi³y ¿adnej faktury firmie maj¹cej siedzibê w Warszawie. W zestawieniu uwzglêdniamy tylko te firmy, które wystawi³y wiêcej ni¿ 10 faktur. Wynik uporz¹dkowaæ malej¹co wed³ug iloœci wystawionych faktur.
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



---W bazie danych EP50_Hurtownia napisaæ zapytanie zwracaj¹ce nastêpuj¹ce dane: nazwê firmy, numer nip oraz iloœæ wystawionych faktur w lutym 2012 dla tych firm, które w lutym 2012 nie wystawi³y ¿adnej faktury firmie maj¹cej siedzibê w Warszawie. W zestawieniu uwzglêdniamy tylko te firmy, które wystawi³y wiêcej ni¿ 10 faktur. Wynik uporz¹dkowaæ malej¹co wed³ug iloœci wystawionych faktur. Podaj firmy, które zajmuj¹ pozycje: 2,4,6 w tym rankingu
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



---W bazie danych EP50_Uczelnia napisaæ zapytanie, które zwraca nastêpuj¹ce dane: nazwisko, imiê i Pesel studentów oraz œredni¹ ocenê z ocen wystawionych przez wyk³adowcê, który w roku 2013 osi¹gn¹³ najwiêkszy przyrost wartoœci œredniej wystawionych ocen z jednego przedmiotu w porównaniu z rokiem 2012. W wyniku uwzglêdniamy tylko tych studentów, który u danego wyk³adowcy otrzymali wiêcej ni¿ 4 oceny. Wynik uporz¹dkowaæ malej¹co wed³ug œredniej.
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


--W bazie danych EP50_Przychodnia przygotowaæ zestawienie zawieraj¹ce nastêpuj¹ce dane; nazwisko, imiê  i Pesel pacjenta oraz iloœæ wizyt danego pacjenta w II pó³roczu 2013. W wyniku uwzglêdniæ tylko tych pacjentów, którzy byli  przynajmniej 5 razy u lekarza. Wynik zapytania uporz¹dkowaæ malej¹co wed³ug iloœci wizyt
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

insert into Tabela1 (Nazwa,Uwagi,DataZdarzenia) values ('nazwa jakaœ','brak uwagi','2018-01-02')
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

---kopiowanie rekordów do istniej¹cej tabeli
delete from OcenyKopia2012
insert into OcenyKopia2012 select idStudenta,IdWykladowcy,idprzedmiotu,idrodzajuoceny,dataoceny,ocena from Oceny where year(DataOCeny)=2012

--TRANSAKCJE
begin transaction;
instrukcja1;
instrukcja2;
instrukcja3;
commit (zatwierdza wykonanie); lub rollback (wycofuje transakcjê );


use EP50_Przychodnia
-- utwórz archiwum wizyt z roku 2012
begin transaction;
select * into Wizyty2012 from Wizyty where YEAR(Wizyty.DataWizyty)=2012;
delete from Wizyty where YEAR(Wizyty.DataWizyty)=2012
commit;

select * from Pacjenci
---podzia³ tabeli Pacjenci na dwie tabele (jedna z tabel zawiera dane tzw. "wra¿liwe")
begin transaction;
select IdPacjenta,Pesel,DataUrodzenia into PacjenciRodo from Pacjenci;
alter table Pacjenci drop column Pesel;
alter table Pacjenci drop column DataUrodzenia; 
commit;

select * from PacjenciRodo

---przychodnia przesz³¹ reorganizacjê. Internista i pediatra za³o¿yli w³asn¹ odrêbn¹ przychodniê. Nale¿y przenieœæ dane lekarzy internistów i pediatrów do innych tabel. Dodatkowo nale¿y przenieœæ wizyty tych lekarzy do innych tabel. Nazwy nowych tabel: Lekarze2 oraz Wizyty2

begin transaction;
select * into Lekarze2 from Lekarze where Lekarze.Idspecjalizacji in (2,3); 
select * into Wizyty2 from Wizyty where Wizyty.IdLekarza in (select Lekarze.IdLekarza from Lekarze where Lekarze.Idspecjalizacji in (2,3));
delete from Lekarze where Lekarze.Idspecjalizacji in (2,3); 
delete from Wizyty where Wizyty.IdLekarza in (select Lekarze.IdLekarza from Lekarze where Lekarze.Idspecjalizacji in (2,3));
commit;

select * from Lekarze2


---w tabeli pacjenci kobietom ustaw pole CzyKobieta na 0, a mê¿czyznom na 1
---zmiana wartoœci pola w tabeli
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