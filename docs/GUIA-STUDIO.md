# Guia de edição no Roblox Studio

## Explorer

| Caminho | Responsabilidade |
|---|---|
| Workspace → LittleWorld → Floor1/2/3 | Terreno, distrito da cidade, casas, árvores, lojas, NPCs e pilar |
| Workspace → LittleWorld → Dungeon1/2/3 | Labirinto de pedra, teto, iluminação, selos e arena |
| Workspace → LittleWorld → Interactions | Marcadores de loja, ferraria, elevador, entrada/saída e selos |
| Workspace → LittleWorld → OreNodes | 30 veios por andar; os nomes começam com o número do andar |
| Workspace → LittleWorld → Spawns | Marcadores de criaturas; formato `tipo_World_índice` ou `tipo_Dungeon_índice` |
| ReplicatedStorage → LittleRPG → Config | Níveis, cidades, inimigos, raridades, chances de drop, áudio e Robux |
| ReplicatedStorage → LittleRPG → Catalog | 60 modelos, dano, alcance, habilidade, receitas e faixas de nível |
| ReplicatedStorage → LittleRPG → Progression | XP, pontos, atributos, inventário e escolha inicial |
| ReplicatedStorage → LittleRPG → Economy | Minérios, escassez, ferraria, probabilidades e estoque |
| ReplicatedStorage → LittleRPG → Maze | Algoritmo determinístico do labirinto usado pelos testes |
| ReplicatedStorage → LittleRPG → WeaponVisual | Modelagem geométrica das armas e previews |
| ServerScriptService → LittleRPGServer → Main | Entrada de jogadores, ações, dano, dash, recompensas e sincronização |
| ServerScriptService → LittleRPGServer → Enemies | Modelos de criaturas, perseguição, caminhos, ataques e respawn |
| ServerScriptService → LittleRPGServer → WorldActions | Mineração, forja, compras, venda de armas e poções |
| ServerScriptService → LittleRPGServer → Dungeons | Servidor reservado, entrada validada, retorno e recuperação de falha |
| ServerScriptService → LittleRPGServer → Profiles | Dados, migração, trava de sessão, autosave e fechamento |
| ServerScriptService → LittleRPGServer → Monetization | Compra direta via ProcessReceipt, sem entrega duplicada |
| StarterPlayer → StarterPlayerScripts → Main | Menu Drácula, escolha inicial, HUD, botões e controles |
| StarterPlayer → StarterPlayerScripts → Animation | Poses R6 para todos os jogadores, sincronizadas por atributos |
| StarterPlayer → StarterPlayerScripts → Effects | Danos flutuantes, sinais de ataque, partículas e sequência de forja |
| StarterPlayer → StarterCharacter | Modelo R6 original com juntas Motor6D editáveis |

## Alterações frequentes

- **Dano e habilidade:** `Catalog.Families`, modelos e `Catalog.Damage`.
- **Limite de nível:** `Config.MaxLevel`; a interface atual exibe 15.000. Atualize também textos e testes se mudar o limite.
- **XP por inimigo:** `Config.Enemies[].XP`.
- **Curva de XP:** `Progression.Required`.
- **Velocidade / dash / defesa:** funções correspondentes em Progression.
- **Minério novo:** adicione à `Economy.OreList` e distribua em `OreChances`. Adicione receitas que usem o minério em Catalog quando o respectivo andar for criado.
- **Escassez de ferro:** fórmula `.18 / (1 + .055 * (andar - 1))` em `OreChances`.
- **Chances de raridade na forja:** `Economy.ForgeOdds`, cuja soma deve continuar sendo 1.
- **Intervalo de estoque:** `Config.StockSeconds`.
- **Nome / preços de poções:** `Config.Consumables`.
- **Produtos de Robux e sons:** `Config.Products` e `Config.Audio`.
- **Tamanho dos mapas / cidades / construções:** `tools/build.py`; sincronize coordenadas de cidade, forja e loja em Config.
- **Forma do labirinto:** `tools/build.py`, função `maze_generate`. O algoritmo equivalente em `Maze.lua` deve permanecer consistente com o gerador. Mudar só o módulo não altera o mapa já gerado.

## Identificadores e dados

Armas são exemplares `{Uid, Blueprint, Rarity}`: duas armas do mesmo modelo podem ter raridades diferentes. O UID distingue os exemplares, inclusive na venda. A arma equipada não pode ser vendida diretamente; equipe outra primeiro.

O mesmo DataStore `LittleRPG_Profiles_v1` é mantido para migrar a versão anterior. Os equipamentos antigos são conservados em `LegacyOwned` e convertidos para equivalentes físicos; níveis, moedas e andares são preservados. Jogadores novos passam pela escolha de arma; jogadores migrados mantêm a arma convertida.

A forma dos mapas é determinística: uma mesma versão dos fontes produz o mesmo `.rbxlx`. No Studio, todos os perfis são temporários para não tocar em dados reais durante desenvolvimento.
