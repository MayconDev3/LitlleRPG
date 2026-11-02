# Little RPG · Ecos de Aether — MVP v2

A segunda versão transforma o protótipo em uma aventura de três andares com cidades, criaturas físicas, mineração, ferraria, labirintos e progressão de atributos. Arte, nomes, armas, modelos e sons são originais, com referências de gênero a aventuras de fantasia e RPGs de torre.

**Estado real:** código implementado, arquivo `.rbxlx` gerado e testes automatizados executados. Ainda é necessária uma rodada no Roblox Studio e uma experiência publicada de teste antes de abrir ao público. Não foi executado um playtest Roblox neste ambiente.

## Abrir e jogar

1. No GitHub Desktop, escolha **MayconDev3/LitlleRPG → Fetch origin → Pull origin**.
2. Use **Repository → Show in Explorer**.
3. Abra **LittleRPG.rbxlx** com Roblox Studio. O arquivo original **Place1.rbxl** permanece separado.
4. Clique em **Play**. Escolha **adaga**, **espada longa de uma mão** ou **rapieira**.
5. Aperte **M** para abrir o menu. São exatamente três abas principais: **Inventário**, **Status** e **Eventos**; a última fica sem eventos.
6. Saia da cidade para encontrar lobos e javalis. O primeiro mapa tem cidade na metade oeste, próxima à borda; a área selvagem fica a leste.
7. Encontre veios de rocha e segure **E** para minerar. Vá à casa do ferreiro, aproxime-se da bancada e use **E** para abrir a forja.
8. No pilar central, use **E** para entrar na dungeon. Explore o labirinto, ative três selos e abra o portão da arena. Vencer o chefe libera o próximo andar pelo elevador da cidade.

### Controles

| Ação | PC | Toque / controle |
|---|---|---|
| Movimento e salto | WASD / Espaço | Controles padrão Roblox |
| Ataque físico | Clique esquerdo | ATACAR / R2 |
| Especial da arma | Z | ESPECIAL / X |
| Dash | Q | DASH / B |
| Correr | Segurar Shift | L3 no controle |
| Interagir / minerar | E | ProximityPrompt nativo |
| Menu | M | MENU / Y |
| Poção de cura / energia | 1 / 2 | Aba Status |

O menu ajusta sua escala ao tamanho da tela. Mouse e toque são os métodos principais de navegação; os atalhos de controle não equivalem a certificação completa de console.

## Conteúdo implementado

| Sistema | Conteúdo |
|---|---|
| Mapas | Três mundos de 1.600 × 1.200 studs, separados verticalmente |
| Cidades | Primeiro andar: distrito oeste de 790 × 1.200 (49,4%); demais: 924 × 693 no centro (33,35%) |
| Dungeon | Pilar central em cada mapa; labirinto de pedra 15 × 15; três selos; arena de chefe; saída para a cidade |
| Instância | Servidor reservado solo no jogo publicado, usando o mesmo PlaceId; modo local de teste no Studio |
| Criaturas | Oito arquétipos no total; lobos e javalis no mundo inicial; 60 pontos de spawn entre mundos e dungeons |
| Armas | Seis categorias × dez modelos = 60 modelos físicos; raridade é uma propriedade separada de cada exemplar |
| Categorias | Adaga, espada de uma mão, rapieira, martelo leve, martelo pesado e espada de duas mãos |
| Raridades | Comum, incomum, rara, épica, mítica, lendária e ultra lendária |
| Escolha inicial | Três cartões com previews 3D; escolha única por perfil novo |
| Combate inicial | Inimigo de nível 1 tem 100 HP e dá 2 XP. Armas iniciais dão 10 por ataque e 34 no especial, antes de melhorias |
| Progressão | Nível 1 exige 4 XP para o nível 2; curva crescente até 15.000; um ponto por nível conquistado |
| Atributos | Força, defesa, movimento e ferraria. Movimento aumenta velocidade e dash com retornos decrescentes |
| Mineração | 90 veios compartilhados; recarga após esgotar; chance de obter apenas pedra; distribuição configurável até andar 100 |
| Ferraria | Molde, minérios, carvão e taxa; sequência de aquecer, derreter, despejar, martelar e resfriar; resultado até mítico |
| Mercadores | Loja por categoria, estoque/falta de estoque, poções de cura e energia e duas melhorias de picareta |
| Estoque | Renovação a cada 30 minutos; cotas individuais por jogador/andar; míticas aparecem apenas no terceiro |
| Robux | Estrutura de compra direta implementada, entrega por recibo e salvamento; IDs desativados por padrão; até lendária |
| Animação | Procedural R6: parado, caminhada, corrida, salto/queda, três golpes, seis especiais, dash, mineração, forja, bebida, interação, dano e morte |
| Salvamento | Trava de sessão, autosave, migração v1, trabalho de forja recuperável e recibos gravados com o perfil |

**Noctífera · Lâmina dos Dois Horizontes** é a espada de duas mãos de desenho próprio, com aço escuro, guarda dupla e detalhes gravados. Sua variante ultra lendária é o drop mais raro do chefe do terceiro andar. Não é vendida por Robux nem produzida na ferraria.

## Como a dungeon separada funciona

No Roblox publicado, o pilar salva e libera o perfil, cria um identificador de servidor reservado e teleporta o jogador para uma instância do **mesmo lugar**. O destino valida uma entrada temporária guardada no perfil. Assim, não é necessário criar um segundo PlaceId para esta versão. A instância é **solo**; convite de grupo e matchmaking não estão incluídos.

No Studio, teleporte entre servidores não é suportado pelo motor. O código usa as dungeons locais presentes no arquivo para testar labirinto, combate e progressão. Para validar a separação de servidor, publique uma experiência de teste e entre pelo aplicativo Roblox.

## Configurar os sons

Os cinco WAVs originais estão em `assets/audio/`. Importe-os para sua conta, autorize a experiência e preencha os IDs em **ReplicatedStorage → LittleRPG → Config → C.Audio**, no formato `rbxassetid://ID`. Sem IDs, o jogo fica sem esses sons. Não foram colocados IDs aleatórios de terceiros.

## Iniciar a loja de Robux

1. Publique uma experiência **privada de teste**.
2. No Creator Dashboard, crie os Developer Products correspondentes às duas ofertas em `C.Products`.
3. Configure nome, descrição e preço, explicando exatamente a arma, a raridade e o nível necessário para equipar.
4. Copie o ID de cada produto para `C.Products[].ProductId` em **Config**. ID `0` mantém a oferta desativada.
5. Replique os mesmos IDs em `src/shared/Config.lua`, se for continuar regenerando o arquivo.
6. Faça os testes de recibo, reconexão e entrega antes de ativar as vendas públicas. O código recusa recibos durante teste local no Studio.

São **compras diretas**, sem caixas aleatórias. O preço é mostrado pela confirmação oficial do Roblox, sem valor inventado na interface. Um Developer Product pode ser comprado mais de uma vez; cada compra entrega um novo exemplar. A mochila cheia deixa a compra pendente para entrega após liberar espaço. Nenhum produto configurado pode conceder ultra lendária.

## Onde ler e editar no Studio

Os scripts estão sem ofuscação, com nomes e comentários. Consulte [GUIA-STUDIO.md](docs/GUIA-STUDIO.md) para o mapa dos módulos. O ambiente, as casas, os NPCs vendedores, a ferraria e os labirintos já são objetos editáveis no Explorer, mesmo fora de Play. Armas, inimigos ativos, UI e efeitos são construídos pelos scripts durante Play.

**Atenção ao arquivo gerado:** `python tools/build.py` recria `LittleRPG.rbxlx` a partir dos scripts e do gerador do mapa. Se editar o mapa diretamente no Studio, salve uma cópia com outro nome ou incorpore as alterações ao gerador antes de reconstruir; a reconstrução substitui o arquivo gerado.

## Validação e publicação

```sh
python tools/build.py
python tools/validate.py
```

O gerador usa Python padrão. O validador usa a biblioteca de sistema **Lua 5.4** para validar o subconjunto de sintaxe Lua empregado e executar testes sem o Roblox. Isso **não** substitui Luau/Studio, física, animação real, renderização, serviços publicados ou testes em celular.

Leia [TESTE-STUDIO.md](docs/TESTE-STUDIO.md) antes de publicar para todos. Esta versão entrega os sistemas do MVP, mas não afirma certificação de produção, balanceamento até o nível 15.000 nem conteúdo jogável para 100 andares. Os níveis elevados e a tabela de minérios são preparação para expansão; há somente três andares jogáveis.

A versão anterior continua acessível no histórico Git, no commit `691fe44837397f3c1c040ebf456678fca10a64cb`. Nenhum arquivo do repositório do Pietro foi utilizado ou alterado nesta atualização.
