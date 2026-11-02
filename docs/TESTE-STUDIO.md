# Testes antes de abrir ao público

**Automático executado:** sintaxe do subconjunto Lua, regras de catálogo/XP/atributos/receitas/estoque, conectividade de labirintos, simulação de falhas de recibo e teleporte, integridade e fontes embutidos no XML.

**Ainda não executado neste ambiente:** carregamento e playtest real no Roblox Studio, teleporte pelo aplicativo Roblox, persistência real, recebimento de compras e avaliação visual/performance em aparelhos reais.

## 1. Carregamento e arte

- Abra LittleRPG.rbxlx e verifique o Output. Confirme casas acessíveis, portas abertas, cidades seguras e um pilar no centro de cada mundo.
- Confirme avatar R6, câmera, arma na mão, modelos nos previews e animação com movimento.
- Observe membros, empunhadura, colisões e altura da câmera; ajuste poses e Tool.Grip se necessário após a inspeção real.
- Veja o primeiro andar: somente lobos e javalis na área selvagem. Confira proporção da cidade e clareza do caminho até o pilar.
- Confirme caminhos da IA: inimigos não devem atravessar as paredes de pedra; registre falhas de navegação para ajustar geometria e AgentRadius.

## 2. Primeiro ciclo jogável

- Escolha uma das três armas; tente escolher outra depois, que deve ser recusado.
- Com perfil novo, derrote dois inimigos de nível 1: 2 XP + 2 XP devem levar ao nível 2, com um ponto.
- Distribua o ponto uma única vez. Confira vida, dano, velocidade, dash e habilidade de ferraria conforme atributo escolhido.
- Teste clique, Z, Q, Shift, energia, recargas, vida, poções, morte e retorno.
- Confira dez ataques básicos de 10 contra inimigo de 100 HP, antes de evoluir atributos. Z deve dar 34 com arma inicial comum.
- Ataques de jogador e inimigo não devem atravessar paredes; ataques não devem causar dano dentro da cidade.

## 3. Mineração e forja

- Minere vários veios até obter minério e carvão. Confira escassez, limite de distância e recarga do veio esgotado.
- Com duas pessoas no mesmo veio, confira que há uma única recompensa quando quebra.
- Forje perto da bancada: débito único, aquecimento, metal líquido, molde, marteladas e arma resultante.
- Confirme modelo do molde para adaga, rapieira e martelo, estado de movimento do personagem e liberação ao terminar.
- Tente fabricar sem recursos, fora da bancada e durante outra fabricação. Nenhum custo extra deve ocorrer.
- Em experiência publicada de teste, desconecte durante fabricação, reconecte e confirme conclusão única do trabalho salvo.

## 4. Loja e interface

- Teste as três abas principais e os submenus. Eventos deve continuar vazio.
- Navegue por categoria antes de ver armas; confira em estoque/fora de estoque, preço e nível.
- Esgote a cota de uma comum, reconecte dentro da mesma janela e confirme a cota. Aguarde renovação e confirme novo estoque.
- Verifique que os dois primeiros andares não vendem míticas e nenhum mercador de moedas vende lendária/ultra.
- Compre e use cura/energia; atualize a picareta; não permita comprar melhoria inferior à atual.
- Venda uma arma não equipada e confira a moeda. Arma equipada não deve ser vendida.
- Em celular horizontal e vertical, teste leitura, rolagem, botão de fechar, escolha inicial e ações de toque.

## 5. Dungeon, progressão e multiplayer

- No Studio, entre no pilar: o modo deve ser explicitamente local de teste.
- Encontre os três selos. O portão da arena deve recusar passagem antes dos três.
- Derrote o chefe, volte à cidade e use o elevador. Não permita viajar para andar ainda bloqueado ou estando longe do elevador.
- Repita o ciclo nos três andares; valide também retorno ao andar anterior.
- Publique em experiência privada e teste pelo aplicativo Roblox: entrar no pilar deve mudar de servidor, com instância solo reservada.
- Faça o retorno e reconecte rapidamente. Perfil, equipamento e desbloqueios devem persistir.
- Com dois clientes públicos, confirme independência de estoque, inventário e pontos; mineração e inimigos são compartilhados no mesmo servidor.

## 6. Dados, áudio e Robux

- IDs 0 devem manter ofertas Robux desativadas. Configure produtos próprios e confirme nome, raridade e preço na janela oficial.
- Teste compra, reconexão, repetição do recibo, mochila cheia e falha de gravação. A entrega não deve duplicar e não deve ser confirmada antes de salvar.
- Não use PromptProductPurchaseFinished para conceder itens; a implementação usa ProcessReceipt.
- Confira migração de perfil v1 sem perda de nível, moedas ou armas convertidas. Faça backup dos dados antes de testes de migração fora de uma experiência isolada.
- Importe os sons originais e confira autorização, volume, silêncio e camada mecânica no andar 3.
- Teste gráficos leves e completos no notebook e em um celular. Esta versão ainda precisa de medição de FPS, memória e carga de servidor no Roblox.

## Limitações conhecidas

- Animações e criaturas são procedurais, sem captura de movimento, malhas esculpidas ou animações publicadas em assets.
- A dungeon reservada é solo; grupo, raid e matchmaking ficam fora deste MVP.
- Os três labirintos são determinísticos. Não se regeneram aleatoriamente a cada entrada.
- A trava de sessão expira em 180 segundos se um servidor cair sem liberar os dados; o autosave é a cada 40 segundos.
- O nível 15.000 é um limite de sistema, não uma afirmação de balanceamento dos três primeiros andares até esse nível.
- Validação de distância, recursos, recarga, propriedade, recibos e estado não substitui auditoria de segurança nem proteção completa contra exploração de movimento.
