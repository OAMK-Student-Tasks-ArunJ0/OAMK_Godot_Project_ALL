Arena Combat RPG
Kehityssuunnitelma 

Osa 1: Perusmekaniikat 

Tavoite: Rakentaa pelaajan liikkuminen, perustilat ja kentän perusrakenne. 
Tehtävät: 

    Player State Machine: Toteuta tilakone pelaajalle, jotta pelitilat (kuten hyökkäys ja vahingoittuminen) ovat hallittavissa ja helposti laajennettavissa. 

    Tilemaps & Tilesets: Luo tilesetit ja niille omat collisionit pelikentän perustoiminnallisuuksia varten. 

    Kamera: Rakenna kamera, joka pysyy pelikentän sisällä eikä seuraa pelaajaa kentän ulkopuolelle. 

Tulokset: Pelaaja voi liikkua sujuvasti kentällä, ja kamera sekä ympäristön reunaelementit toimivat odotetusti. 


Osa 2: Taistelu ja viholliset 

Tavoite: Toteuttaa taistelumekaniikat ja lisätä yksinkertainen vihollinen. 
Tehtävät: 

    Hitboxit: Luo pelaajan ja vihollisten käyttämät hitboxit osumatunnistusta varten. 

    Pelaajan hyökkäystila: Lisää hyökkäystila pelaajan tilakoneeseen. 

    Enemy: Luo vihollinen, jolla on oma tilakone samankaltaisista syistä kuin pelaajalla. 

    Pelaajan terveys: Lisää pelaajan terveydenhallinta ja mahdollisuus ottaa vahinkoa. 

Tulokset: Pelaaja voi taistella vihollisia vastaan, ja sekä pelaajalla että vihollisella on perustason terveydenhallinta. 


Osa 3: Käyttöliittymä ja pelaajamekaniikat 

Tavoite: Lisätä pelaajan HUD ja perusmekaniikat kenttien vaihtoa ja uudelleensyntymistä varten. 
Tehtävät: 

    Player HUD: Aloita ja viimeistele pelaajan health bar ja muut tarvittavat UI-elementit. 

    Player Spawner: Toteuta pelaajan uudelleensyntyminen kuoleman tai kentän vaihtamisen yhteydessä. 

    Scene Manager: Rakenna järjestelmä, joka hallitsee pelaajan siirtymistä kentältä toiselle. 

Tulokset: Pelaajan terveys näkyy HUD:issa, ja pelaajan siirtyminen kenttien välillä toimii sujuvasti. 


Osa 4: Tallennus, inventaario ja esineet 

Tavoite: Lisätä tallennusjärjestelmä, inventaario ja esineiden keräys. 
Tehtävät: 

    Save ja Load System: 

    Toteuta järjestelmä, joka tallentaa ja lataa pelaajan x/y-sijainnin, nykyisen kentän, terveyden ja inventaarion. 

    Save permanency: Varmista, että muutokset kartoissa (esim. avatun arkun sisältö) tallentuvat pysyvästi. 

    Inventory/Item System: 

    Toteuta esineiden kerääminen kentiltä. 

    Luo inventaarionäkymä, jossa pelaaja voi tarkastella ja käyttää kerättyjä esineitä. 

    Item keräys vihollisilta: Lisää logiikka, jonka avulla viholliset voivat pudottaa esineitä kuollessaan. 

    Laatikot ja tavarat: Toteuta interaktiivisia laatikoita, jotka pelaaja voi avata saadakseen esineitä. 

Tulokset: Pelaaja voi tallentaa ja ladata pelitilanteen, hallita inventaariotaan ja kerätä esineitä, ja kaikki muutokset tallentuvat pysyvästi. 


Osa 5: Laajennettu taistelumekaniikka ja viholliset 

Tavoite: Lisätä erilaisia vihollistyyppejä, pelaajan kykyjä ja boss-taisteluja. 
Tehtävät: 

    Vihollistyypit: 

    Luo erilaisia vihollisia, joilla on erityiskykyjä (esim. ranged attack, area attack). 

    Lisää pomovihollisia erityishyökkäyksillä. 

    Pelaajan kyvyt: 

    Lisää pelaajalle ranged-hyökkäys ja dodge/dash-toiminto. 

    Balanssi: Hienosäädä taistelumekaniikoita ja vaikeustasoa. 

Tulokset: Taistelut ovat monipuolisempia, ja pelaajalla on lisää kykyjä ja strategisia vaihtoehtoja. 


Osa 6: Shop System ja NPC 

Tavoite: Rakentaa shopjärjestelmä, jossa pelaaja voi ostaa esineitä ja parannuksia. 
Tehtävät: 

    Shop System: 

    Luo shopnäkymä, jossa pelaaja voi ostaa esineitä ja parannuksia. 

    Luo oma rahajärjestelmä, jossa pelaaja voi ansaita rahaa taisteluista tai esineiden myynnistä. 

    NPC-järjestelmä: 

    Lisää NPC-hahmo, joka toimii kauppiaana ja jonka kanssa pelaaja voi kommunikoida. 

    Parannukset: 

    Pelaaja voi käyttää kerättyjä esineitä ostaakseen päivityksiä hahmolle tai avatakseen uusia kykyjä. 

Tulokset: Pelaaja voi ostaa ja myydä esineitä kaupasta ja käyttää resursseja hahmon parantamiseen. 


Osa 7: Gameplay Loop 

Tavoite: Rakentaa toimiva pelisykli, jossa pelaaja siirtyy kartalta toiselle ja käyttää shop/upgrade-mekaniikkoja. 
Tehtävät: 

    Gameplay Loop: 

    Pelaaja siirtyy arena-kartoilta shop/middle-karttoihin ja takaisin. 

    Pelaaja voi tallentaa vain shop/middle-kartoilla. 

    Shop/middle-kartoilla pelaaja voi käyttää kerättyjä esineitä ostaakseen parannuksia tai uusia kykyjä. 

    Pelaajan edistys: 

    Pelaaja voi parantaa hahmoaan shopissa tai tekemällä valintoja kentillä. 

Tulokset: Pelisykli toimii sujuvasti, ja pelaaja voi edetä pelissä käyttämällä kaupasta saatavia parannuksia. 


Osa 8: Viimeistely 

Tavoite: Viimeistellään peli ja korjataan virheitä. 
Tehtävät: 

    Pelitestaus: Etsi ja korjaa kaikki löydetyt virheet. 

    Balansointi: Viimeistele pelin vaikeustaso ja vihollisten/kykyjen tasapaino. 

    Viimeistely: 

    Lisää ääniä, animaatioita ja visuaalisia tehosteita. 

    Viimeistele käyttöliittymä ja pelikokemus. 

Tulokset: Valmis ja pelattava peli. 