# 2D Top-Down RPG

Tämä on 2D top-down RPG -peli, joka on tehty Godot Engineä käyttäen. Projekti on rakennettu selkeän arkkitehtuurin pohjalta ja sisältää globaalit järjestelmät, vihollisten tekoälyn, pelaajan mekaniikat, käyttöliittymän ja vuorovaikutteiset elementit. Projekti on toteutettu opinnäytetyönä, ja siihen sisältyy laaja dokumentaatio pelisuunnittelusta, mekaniikoista, testauksesta ja kehityksestä.

[Projektin tiedostot OneDrivessa](https://unioulu-my.sharepoint.com/:f:/r/personal/t0nian05_students_oamk_fi/Documents/Opinn%C3%A4ytety%C3%B6%20-%20Arena%20Game?csf=1&web=1&e=YLwJug)

---

## Vaatimukset

- **Godot Engine 4.3 tai uudempi**  
  Lataa ja asenna [Godot Engine](https://godotengine.org/download).


## Näin avaat ja käynnistät projektin Godotilla

1. **Avaa Godot Editor**  
   Käynnistä Godot Editor koneellasi.
2. **Tuo projekti**  
   Klikkaa Godotin Project Managerissa **"Import"** ja selaa kansioon, jossa `project.godot` sijaitsee.
3. **Tarkista editorin asetukset (tarvittaessa)**  
   Varmista, että esimerkiksi `.vscode/settings.json` on ajan tasalla.
4. **Käynnistä projekti**  
   Paina F5 tai klikkaa **"Play"** -painiketta pelin suorittamiseksi.

---

## Sisällysluettelo

- [Yleiskatsaus](#yleiskatsaus)
- [Projektin rakenne](#projektin-rakenne)
- [Yksityiskohtainen dokumentaatio](#yksityiskohtainen-dokumentaatio)
  - [Globaalit järjestelmät ja managerit](#globaalit-järjestelmät-ja-managerit)
  - [Vihollisten tekoäly ja käyttäytyminen](#vihollisten-tekoäly-ja-käyttäytyminen)
  - [Pelaajan mekaniikat ja kyvyt](#pelaajan-mekaniikat-ja-kyvyt)
  - [Vuorovaikutteiset elementit](#vuorovaikutteiset-elementit)
  - [Tasot ja ympäristö](#tasot-ja-ympäristö)
  - [Käyttöliittymä (GUI)](#käyttöliittymä-gui)
  - [Inventaario- ja kauppajärjestelmät](#inventaario--ja-kauppajärjestelmät)
  - [Tallennus- ja latausjärjestelmä](#tallennus--ja-latausjärjestelmä)
- [Vaatimukset](#vaatimukset)
- [Näin avaat ja käynnistät projektin Godotilla](#näin-avaat-ja-käynnistät-projektin-godotilla)
- [Testaus ja kehitys](#testaus-ja-kehitys)
- [Tekijät ja ohjaus](#tekijät-ja-ohjaus)
- [Lähteet](#lähteet)

---

## Yleiskatsaus

Tämä projekti on 2D-roolipeli, joka sisältää klassisia RPG-elementtejä:
- **Hahmonkehitys:** Pelaaja ohjaa hahmoa, joka kehittyy uusien kykyjen ja varusteiden myötä.
- **Taistelumekaniikat:** Peli sisältää sekä lähitaistelu- että etätaistelun, joissa vihollisten kehittynyt tekoäly tekee taisteluista haastavia.
- **Vuorovaikutteinen ympäristö:** Pelaaja tutkii tarkasti rakennettuja tasoja, joissa on interaktiivisia objekteja kuten ovia, arkkuja, tynnyreitä ja pulmia.
- **Käyttöliittymä:** Pelin HUD, inventaario, päävalikko ja kuolemanäkymä ohjaavat pelaajaa pelin aikana.
- **Tallennusjärjestelmä:** Laadukas tallennus- ja latausjärjestelmä säilyttää pelaajan edistymisen ja pelin tilan.

Projektin tarkoituksena on tuottaa toimiva RPG, joka täyttää kaupallisten roolipelien perusvaatimukset sekä tarjoaa syvällisen katsauksen pelisuunnittelun ja Godot-pelimoottorin hyödyntämiseen.

---

## Projektin rakenne

Projektin pääosat ovat:

### Globaalit järjestelmät
- **Globaalit managerit:**  
  - `global_audio_manager.gd` hallitsee taustamusiikkia ja ääniefektejä.
  - `global_level_manager.gd` vastaa tasojen latauksesta ja siirtymisestä.
  - `global_player_manager.gd` kontrolloi pelaajan tilaa, spawnauksia ja attribuutteja.
  - `global_save_manager.gd` huolehtii tallennuksista ja latauksista.

### Viholliset
- **Scenet ja skriptit:**  
  - Vihollistyyppien (esim. `bunny.tscn`, `orc_boss.tscn`, `slime.tscn`) toiminta määritellään omissa sceneissään.
  - Käyttäytymisen ohjaus hoituu skripteillä kuten `enemy.gd`, `enemy_state_attack.gd`, `enemy_state_idle.gd` jne.
  - Erikoisjärjestelmiä, kuten `enemy_attack_range.tscn` ja `navigator.tscn`, hyödynnetään tekoälyn tehostamiseen.

### Pelaaja
- **Pelaaja ja varusteet:**  
  - Pelaajan ja hänen varusteidensa (esim. `player.tscn`, `bomb.tscn`, `knife.tscn`, `shuriken.tscn`) toteutus tapahtuu scene-tiedostoilla.
  - Pelaajan logiikka ja tilakoneen hallinta ovat skripteissä, kuten `player.gd`, `player_state_machine.gd`, `state_attack.gd`, jne.
  - Erikoiskyvyt (dash, etä- ja lähitaistelu) ovat hallinnassa `Abilities.gd`-skriptissä.

### Vuorovaikutteiset elementit
- **Ympäristön objektit:**  
  - Interaktiiviset esineet kuten ovet (`closed_door.tscn`, `key_door.tscn`), arkut, tynnyrit ja kysymysmerkit toteutetaan scene-tiedostoina ja niiden logiikka löytyy skripteistä (esim. `closed_door.gd`, `key_door.gd`, `chest.gd`).

### Esine- ja kauppajärjestelmät
- **Esineiden hallinta:**  
  - Esineiden tiedot ja vaikutukset määritellään skripteissä kuten `item_data.gd` ja `item_effect.gd`.
  - Kauppajärjestelmä koostuu omista sceneistään (esim. `merchant.tscn`, `merchant_ui.tscn`) sekä skripteistä kuten `merchant_data.gd` ja `merchant.gd`.

### Tasot
- **Tasojen rakentaminen:**  
  - Tasot toteutetaan scene-tiedostoina (esim. `00_Dungeon.tscn`, `01_Dungeon.tscn`, `level_transition.tscn`, `player_spawn.tscn`).
  - Tasojen logiikasta huolehtivat skriptit kuten `level_tile_map.gd`, `level_transition.gd` ja `level.gd`.

---

## Yksityiskohtainen dokumentaatio

Tässä osiossa esitellään lyhyesti projektin keskeiset osat ja niiden toteutus:

### Globaalit järjestelmät ja managerit

- **AudioManager:**  
  Hallitsee pelin musiikkia ja ääniefektejä, mahdollistaa äänenvoimakkuuden säädön ja fade-in/fade-out-efektit.
  
- **LevelManager:**  
  Vastaa tasojen siirtymisestä, pelaajan sijoittamisesta uusiin kenttiin sekä collision-alueiden varmistamisesta.
  
- **PlayerManager:**  
  Käsittelee pelaajan spawnauksen, terveystilanteen, kykyjen käytön ja pitää tilan yhtenäisenä tasojen välillä.
  
- **SaveManager:**  
  Toteuttaa JSON-pohjaisen tallennus- ja latausjärjestelmän, joka säilyttää pelaajan sijainnin, terveyden, inventaarion ja muut tärkeät tilat.

### Vihollisten tekoäly ja käyttäytyminen

- **Tilakoneet:**  
  Jokainen vihollinen käyttää tilakonetta, joka hallitsee tiloja kuten idle, kävely, charge, hyökkäys, vahingoittuminen ja kuolema.
  
- **Navigointi:**  
  Navigator-nodet ja RayCast2D -solmut auttavat vihollisia liikkumaan esteiden ohi ja optimoimaan liikesuunnat.
  
- **Hyökkäysmekaniikat:**  
  Hyökkäykset toteutetaan erillisillä skripteillä ja HitBox/HurtBox -järjestelmillä, jotka varmistavat osumien ja vahinkolaskennan.

### Pelaajan mekaniikat ja kyvyt

- **Liikkuminen ja animaatiot:**  
  Pelaaja liikkuu state machine -pohjalla, joka tukee useita suuntia (pää- ja diagonaaliset liikkeet). Animaatiot ohjataan AnimationPlayer-nodella, joka synkronoi liikkeet ja tilamuutokset.
  
- **Taistelukyky:**  
  Perushyökkäys, dash ja etä-/lähitaistelukyvyt ovat tarkasti ajastettuja ja toteutettu Godotin timer- ja signal-järjestelmillä.

### Vuorovaikutteiset elementit

- **Ovet ja avaimet:**  
  Ovet (closed_door.tscn ja key_door.tscn) vaihtavat tilaansa pelaajan vuorovaikutuksen ja avainten käytön perusteella.
  
- **Esineiden pudotus ja keräys:**  
  ItemNode ja EnemyStateDeath vastaa esineiden luomisesta kentälle, ja ne kerätään automaattisesti inventaarioon.
  
- **Ympäristöobjektit:**  
  Tynnyrit, arkut ja muut objektit reagoivat pelaajan toimintaan ja voivat käynnistää erilaisia tapahtumia kentällä.

### Tasot ja ympäristö

- **TileMap ja collision:**  
  Tasot rakennetaan TileMap-järjestelmällä, jossa eri kerrokset (Walls, Ground, AccessoryTiles) määrittävät kentän rakenteen ja collision-alueet.
  
- **Tason siirtymät:**  
  Pelaajan spawnaukset ja level_transition-nodet mahdollistavat sujuvat siirtymät kentältä toiselle, myös visuaalisin SceneTransition-animaatioin.

### Käyttöliittymä (GUI)

- **HUD:**  
  Näyttää pelaajan terveyden, kykyjen odotusajat ja muut keskeiset pelitiedot.
  
- **Valikot:**  
  Päävalikko, inventaario, asetukset ja kuolemanäkymä (DeathScreen) ovat toteutettu omissa sceneissään ja skripteissään, jotka hallitsevat käyttäjäsyötettä ja tilojen vaihtoa.
  
- **Reaktiivisuus:**  
  UI-komponentit päivittyvät reaaliajassa, mikä varmistaa selkeän ja johdonmukaisen pelikokemuksen.

### Inventaario- ja kauppajärjestelmät

- **Inventaario:**  
  Inventaario toimii ruudukkomaisena järjestelmänä, jossa esineet listataan ja niitä voidaan käyttää suoraan. Esineiden tiedot tallennetaan erilliseen resurssiin.
  
- **Kauppajärjestelmä:**  
  Merchant UI mahdollistaa esineiden ostamisen ja myymisen pelin valuutalla (Gem). Kaupan tiedot haetaan omista resurssitiedostoista ja hintalaskenta perustuu ennalta määriteltyihin kertoimiin.

### Tallennus- ja latausjärjestelmä

- **Tallennus:**  
  Pelaajan sijainti, terveys, inventaario ja muut tilat tallennetaan JSON-muotoon, jolloin tiedot ovat helposti luettavissa ja muokattavissa.
  
- **Pysyvyys:**  
  Tietyt objektien tilat, kuten avatut ovet ja suoritetut tehtävät, säilyvät myös kenttien vaihdon jälkeen.

---

## Tekijät ja ohjaus

- **Tekijä:**  
  Antti-Jussi Niku  
  *Opinnäytetyö – 2D-Roolipelin Toteutus Godot:illa*  
  Oulun ammattikorkeakoulu, Tieto- ja Viestintätekniikka  
  Kevät 2025

- **Työn ohjaaja:**  
  Teemu Leppänen


## Lähteet

- [Godot Engine Documentation](https://docs.godotengine.org/en/stable/)
- [GodotTutorials – Making a 2D RPG in Godot (YouTube)](https://youtu.be/QKgTZWbwD1U?si=j0EnzZ4satHnZYjR)
- [GodotTutorials – 2D RPG Enemy AI in Godot (YouTube)](https://youtu.be/ow_Lum-Agbs?si=ssrECaODPsY7jTKv)
- [GodotTutorials – 2D RPG Mechanics in Godot (YouTube)](https://youtu.be/LOhfqjmasi0?si=4cNr2VJv9yd5dUWM)
