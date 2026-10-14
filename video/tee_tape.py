"""Rakentaa vhs-tapen PokeStock-demovideota varten."""
import re, sys
repo, out = sys.argv[1], sys.argv[2]
q = open(f"{repo}/database/04_kyselyt.sql").read()
# kyselyt: kommenttiotsikko + SELECT ... ;
blocks = re.findall(r"-- -+\n((?:-- [^\n]*\n)+)-- -+\n(SELECT.*?;)", q, re.S)

L = []
def typ(s): L.append("Type `" + s + "`")
def enter(sec=0.4): L.append("Enter"); L.append(f"Sleep {sec}s")
def sleep(sec): L.append(f"Sleep {sec}s")
def cmd(s, sec=2): typ(s); sleep(0.3); enter(sec)
def otsikko(teksti, sec=3):
    cmd("clear", 0.3)
    cmd(f"banner '{teksti}'", sec)

L += [f"Output \"{out}\"", "Set Shell bash", "Set FontFamily \"JetBrainsMono Nerd Font\"",
      "Set FontSize 17", "Set Width 1920", "Set Height 1080", "Set Padding 24",
      "Set Theme \"Catppuccin Mocha\"", "Set TypingSpeed 35ms", "Set Framerate 30",
      "Hide",
      "Type `source ./alustus.sh && clear`", "Enter", "Sleep 1s",
      "Show"]

otsikko("PokeStock – SQL-tietokantaprojekti", 2)
cmd("ls database", 6)

# 1. Luonti
otsikko("1. Tietokannan luonti (01_schema.sql)")
cmd("bat --paging=never --style=numbers database/01_schema.sql | head -45", 14)
cmd("bat --paging=never --style=numbers database/01_schema.sql | sed -n '46,200p'", 14)
cmd("mysql -u root < database/01_schema.sql", 2)
cmd("mysql -u root -t -e 'USE pokestock; SHOW TABLES; DESCRIBE Myynti;'", 12)

# 2. Alustus
otsikko("2. Alustus: testitiedot (03_esimerkkidata.sql)")
cmd("bat --paging=never --style=numbers database/03_esimerkkidata.sql | head -40", 12)
cmd("bat --paging=never --style=numbers database/03_esimerkkidata.sql | tail -35", 14)
cmd("mysql -u root < database/03_esimerkkidata.sql", 2)
cmd("mysql -u root -t pokestock < rivimaarat.sql", 8)

# 3. Kyselyt
otsikko("3. SQL-kyselyt (04_kyselyt.sql)")
cmd("bat --paging=never --style=numbers database/04_kyselyt.sql | head -18", 10)
for i, (kommentti, sql) in enumerate(blocks, 1):
    cmd("clear", 0.3)
    cmd(f"bat --paging=never --style=plain kyselyt/kysely{i:02d}.sql", 5)
    cmd(f"mysql -u root -t pokestock < kyselyt/kysely{i:02d}.sql", 14)

# 4. Varmuuskopio
otsikko("4. Tietokannan varmuuskopiointi (mysqldump)")
cmd("mysqldump -u root --single-transaction --set-gtid-purged=OFF pokestock > pokestock_backup.sql", 2)
cmd("ls -lh pokestock_backup.sql", 3)
cmd("grep -n -E 'CREATE TABLE|INSERT INTO' pokestock_backup.sql | cut -c1-110", 10)

# 5. Palautus
otsikko("5. Palautus uuteen tietokantaan")
cmd("mysql -u root -e 'CREATE DATABASE pokestock_palautus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'", 3)
cmd("mysql -u root pokestock_palautus < pokestock_backup.sql", 3)
cmd("mysql -u root -t -e 'SHOW DATABASES;'", 6)
cmd("clear", 0.3)
cmd("mysql -u root -t", 2)
cmd("USE pokestock_palautus;", 2)
cmd("SELECT DATABASE() AS aktiivinen_kanta;", 5)
cmd("source rivimaarat.sql", 8)
cmd("source kyselyt/kysely09.sql", 12)
cmd("exit", 2)
cmd("banner 'Kiitos!'", 4)
open(out.replace('.mp4', '.tape'), "w").write("\n".join(L) + "\n")

# kyselyt omiin tiedostoihinsa: kommentti + kysely, jotta -t tulostaa siistin taulukon
import os
os.makedirs("kyselyt", exist_ok=True)
for i, (kommentti, sql) in enumerate(blocks, 1):
    open(f"kyselyt/kysely{i:02d}.sql", "w").write(kommentti + sql + "\n")
print(len(blocks), "kyselyä")
