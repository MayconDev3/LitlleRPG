# Little RPG · Ecos de Aether

Uma primeira versão jogável original para Roblox: exploração de uma torre de três andares, paisagens suspensas, personagens angulares, tecnologia antiga e interface unificada. As referências de direção são aventuras de fantasia e RPGs de torre; não há mapas, personagens, marcas, músicas ou modelos extraídos das franquias citadas.

## Abrir no seu computador

1. No GitHub Desktop, escolha **MayconDev3/LitlleRPG**, clique **Fetch origin** e, se aparecer, **Pull origin**.
2. Clique em **Repository → Show in Explorer**.
3. Abra **LittleRPG.rbxlx** com o Roblox Studio. O arquivo **Place1.rbxl** anterior foi preservado.
4. O mapa já aparece no editor. Clique em **Play / Jogar** para carregar personagem, interface e inimigos.
5. Caminhe pela estrada, aproxime-se de um inimigo, olhe na direção dele e clique para atacar. No celular, use **ATACAR**.
6. Aperte **M** ou clique em **MENU**. Na aba Inventário, clique em **MOCHILA / FORJA** para alternar seus itens e os 50 equipamentos disponíveis. Clique em um item e em Equipar ou Criar.
7. Para disponibilizar o jogo, use **File → Publish to Roblox As…** em uma experiência nova. Não publique por cima do jogo do Pietro.

## O que foi implementado

- Três mapas construídos no arquivo: Campos da Aurora, Jardim Prismático e Cidadela do Eco.
- Níveis 1–100, XP, cristais, inventário, compra de armas, drops e equipamento físico na mão.
- 50 armas: cinco famílias × dez faixas. Cada família tem dano, alcance, intervalo e geometria próprios.
- Oito arquétipos de inimigo, 21 pontos de nascimento, perseguição, retorno à origem e respawn.
- Um chefe em cada andar. Ataques têm área vermelha e atraso para permitir esquiva por movimento.
- Andar 2 exige chefe do andar 1 e nível 30; andar 3 exige chefe do andar 2 e nível 65.
- Três abas: Inventário, Personagem e Eventos. Eventos fica sem atividades, conforme solicitado.
- Santuários recuperam vida; morte reaparece no andar atual; queda retorna ao santuário com penalidade de vida.
- Avatar R6 original, animação procedural, iluminação, atmosfera, bloom e opção de gráficos leves.
- Salvamento com trava de sessão, autosave, salvamento na saída e encerramento. O Studio usa sessão temporária, sem escrever nos dados publicados.
- Controles: WASD/movimento padrão Roblox, Espaço para pular, clique para ataque, M para menu. Toque e botões de controle Y/R2 também têm atalhos.

## Ativar os sons originais

Os cinco WAVs de `assets/audio/` foram sintetizados para este projeto. **O jogo inicia sem áudio até a importação**: o Roblox exige assets hospedados e autorizados para a experiência.

1. Importe `Ambient.wav`, `Machine.wav`, `Menu.wav`, `Hit.wav` e `LevelUp.wav` na sua conta pelo Creator Dashboard/Asset Manager.
2. Conceda à experiência permissão para usar esses assets.
3. No Explorer do Studio, abra **ReplicatedStorage → LittleRPG → Config**.
4. Em `C.Audio`, preencha cada entrada com `"rbxassetid://SEU_ID"`.
5. Salve e publique novamente. Se mantiver os fontes como referência, copie os mesmos IDs em `src/shared/Config.lua` antes de regenerar o lugar.

`Ambient` é um motivo calmo com timbres harmônicos; `Machine` é uma camada eletrônica para o terceiro andar. Os outros arquivos são efeitos de interface, impacto e evolução.

## Desenvolvimento e verificações

O `.rbxlx` é gerado exclusivamente dos fontes e de `tools/build.py`. Executar `python tools/build.py` regenera o arquivo e **substitui edições feitas diretamente nesse arquivo gerado**. Guarde qualquer mapa editado no Studio com outro nome ou incorpore as mudanças ao gerador antes de reconstruir.

```sh
python tools/build.py
python tools/audio.py
python tools/validate.py
```

O validador usa a biblioteca de sistema Lua 5.4 para checar o subconjunto Lua utilizado, regras puras de progressão e integridade do XML. Não substitui o runtime Luau/Roblox. Consulte `docs/TESTE-STUDIO.md` para as verificações de engine, multiplayer e persistência.

Esta entrega é uma primeira versão implementada, não um jogo comercial acabado. Não foi possível executar Roblox Studio neste ambiente. Balanceamento, movimentação de NPCs, alcance de armas, câmera, carregamento do XML, áudio após importação e comportamento em aparelhos reais precisam do teste descrito. NPCs usam navegação direta nos corredores abertos, sem busca de caminho para mapas arbitrários. Não há missões narrativas, PvP, monetização nem eventos inventados.

### Documentação de referência

- [Data stores](https://create.roblox.com/docs/cloud-services/data-stores)
- [Segurança cliente–servidor](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- [Session locking e dados de jogadores](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing)
