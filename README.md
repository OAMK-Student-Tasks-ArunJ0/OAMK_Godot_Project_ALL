[OneDrive Link](https://unioulu-my.sharepoint.com/:f:/r/personal/t0nian05_students_oamk_fi/Documents/Opinn%C3%A4ytety%C3%B6%20-%20Arena%20Game?csf=1&web=1&e=YLwJug)

# 2D Top-Down RPG

Tämä on 2D top-down RPG -peli, joka on tehty Godot Engineä käyttäen. Projektissa on selkeä rakenne, joka kattaa globaalit järjestelmät, vihollisten AI:n, pelaajan mekaniikan, käyttöliittymän ja vuorovaikutteiset elementit.

---

## Projektin rakenne

- **Globaalit järjestelmät**  
  Globaalit skriptit, kuten `global_audio_manager.gd`, `global_level_manager.gd`, `global_player_manager.gd` ja `global_save_manager.gd`, huolehtivat äänistä, tasoista, pelaajan tilasta ja tallennuksista.

- **Viholliset**  
  Viholliset ovat .tscn-tiedostoja (esim. `bunny.tscn`, `orc_boss.tscn`, `slime.tscn`), ja niiden toimintaa ohjaavat .gd-skriptit (kuten `enemy.gd`, `enemy_state_attack.gd`, `enemy_state_idle.gd`, `enemy_state_hurt.gd` jne.). Lisäksi erikoistoiminnot, kuten `enemy_attack_range.tscn`, `enemy_bomb.tscn` ja `navigator.tscn`, täydentävät vihollisten käyttäytymistä.

- **Pelaaja**  
  Pelaajan eri tilat ja visualisointi on toteutettu .tscn-tiedostoilla (esim. `player.tscn`, `bomb.tscn`, `knife.tscn`, `shuriken.tscn`). Pelaajan toimintalogiikkaa ohjaavat skriptit (kuten `player.gd`, `player_state_machine.gd`, `state_attack.gd`, `state_idle.gd`, `state_dash.gd` jne.), ja erityiskyvyt (dash, etäaseet, lähitaistelu) ovat hallinnassa `Abilities.gd`-skriptissä.

- **Käyttöliittymä**  
  Käyttöliittymä (HUD, inventaario, päävalikko jne.) on rakennettu .tscn-tiedostoilla (esim. `main_menu.tscn`, `player_hud.tscn`, `inventory_menu.tscn`, `death_screen.tscn`, `health_bar.tscn`) ja niiden toiminnallisuus on toteutettu .gd-skripteillä (kuten `main_menu.gd`, `inventory_ui.gd`, `player_hud.gd`, `death_screen.gd`, `health_bar.gd`).

- **Vuorovaikutteiset elementit**  
  Interaktiiviset esineet ja ympäristön elementit (esim. `closed_door.tscn`, `key_door.tscn`, `question_mark.tscn`, `barrel.tscn`, `chest.tscn`) on toteutettu .tscn-tiedostoina, ja niiden logiikka löytyy skripteistä kuten `closed_door.gd`, `key_door.gd`, `item_dropper.gd` ja `chest.gd`.

- **Esine- ja kauppajärjestelmät**  
  Esineiden logiikka on tehty .gd-tiedostoilla (kuten `item_data.gd`, `item_effect.gd`, `item_effect_heal.gd`, `item_effect_weapon_upgrade.gd`), ja esineet näkyvät .tscn-tiedostojen (esim. `item_node.tscn`) kautta. Kauppajärjestelmä koostuu omista skenaarioistaan (kuten `merchant.tscn`, `merchant_ui.tscn`, `item_slot_shop.tscn`) sekä skripteistä, kuten `merchant_data.gd` ja `merchant.gd`.

- **Tasot**  
  Tasot on rakennettu .tscn-tiedostoina (esim. `00_Dungeon.tscn`, `01_Dungeon.tscn`, `level_transition.tscn`, `player_spawn.tscn`) ja niiden toiminta ohjataan .gd-skripteillä (kuten `level_tile_map.gd`, `level_transition.gd`, `level.gd`, `player_spawn.gd`). Pelimaailman ilme muodostuu ympäristöelementeistä, taustakuvioista ja laattakartoista.

---

## Mitä tarvitset

- **Godot Engine 4.0 tai uudempi**  
  Lataa [Godot Engine](https://godotengine.org/download) –sivustolta ja asenna.

---

## Näin avaat projektin Godotilla
1. **Lataa tai kloona projektin**  
   Voit käyttää Gitä:
   ```bash
   git clone <repository-url>
2. **Avaa Godot Editor**
3. **Käynnistä Godot Editor.**
4. **Tuo projekti**
    Klikkaa Godotin Project Managerissa "Import".
    Selaa kansioon, johon projekti on tallennettu, ja valitse project.godot -tiedosto.
    Klikkaa "Import & Edit" avataksesi projektin.
5. **Muokkaa editorin asetuksia (tarvittaessa)**
    Varmista, että editorin konfiguraatiot, kuten .vscode/settings.json, ovat kunnossa.
6. **Käynnistä projekti**
    Paina F5 tai klikkaa "Play" -painiketta projektin suorittamiseksi.

## Vinkkejä ja ohjeita

- **Tutustu projektin rakenteeseen:**
    Tarkastele Godotin FileSystem-dokkia saadaksesi yleiskuvan kansioiden ja skriptien järjestelystä.
- **Skriptit ja dokumentaatio:**
    Skripteissä on kattavat kommentit, jotka auttavat ymmärtämään logiikkaa ja toimintaa.
