# Regras do MVP

## Primeiro combate

Lobo e javali de nível 1 têm 100 HP e concedem 2 XP. Cada inicial comum tem 10 de dano e especial de 34, com consumo de energia e recarga próprios. Sem melhorias, são dez ataques básicos; o especial remove aproximadamente um terço da vida. Adaga, rapieira e espada diferem em alcance e intervalo.

Do nível 1 ao 2 são necessários 4 XP. Para um nível `n`, a exigência é `floor(4 × n^1,35 × (1 + (n - 1)/250))`. O nível máximo é 15.000. Cada nível conquistado gera um ponto, sem ganho adicional de pontos após o limite. Os três andares iniciais não oferecem conteúdo balanceado para atravessar toda a curva até 15.000.

Movimento usa curvas limitadas: velocidade `18 + 12p/(p+15)`; alcance do dash `16 + 24p/(p+30)`. Os ganhos iniciais são mais perceptíveis e nunca crescem indefinidamente. Força e defesa também têm retornos decrescentes; defesa máxima por pontos se aproxima de 65%.

## Drops de arma

- Inimigo comum: 2% de chance de cair uma arma.
- Chefe: 15% de chance de cair uma arma.
- Dentro de um drop: pesos 6000, 2600, 1000, 320, 70, 9 e 1, na ordem das sete raridades.
- A chance de ultra só é válida para o Soberano da Forja. Nos outros inimigos, esse resultado vira lendária.
- A ultra do Soberano é sempre a Noctífera, espada de duas mãos do modelo 10. A chance final é 0,0015% por vitória elegível (15% × 1/10.000).
- Recompensa exige contribuição de pelo menos 5% do HP e presença no mesmo andar/modo, a até 140 studs da derrota.

Essas taxas são parâmetros iniciais, não valores comprovados por uma economia em produção. Teste a retenção e o tempo de obtenção antes de consolidá-las.

## Ferraria

Cada modelo pede minério específico, dois carvões e uma taxa em moedas. Ferraria efetiva depende de pontos no atributo e experiência adquirida ao fabricar. O resultado varia de comum a mítico; lendária e ultra não são resultados da forja.

| Raridade | Habilidade 0 | Habilidade 100 |
|---|---:|---:|
| Comum | 78% | 50% |
| Incomum | 18% | 28% |
| Rara | 3,5% | 13,5% |
| Épica | 0,4% | 6,9% |
| Mítica | 0,1% | 1,6% |

A receita é debitada uma vez. Um trabalho pendente salvo é concluído ao reconectar, evitando perder o custo por interromper a animação. Como qualquer dado com autosave, uma queda abrupta pode reverter alterações desde a última gravação.

## Minérios e expansão

Os 90 veios compartilhados produzem no máximo uma unidade de minério quando quebrados. Pedra sem minério é um resultado possível. Ferro é escasso no primeiro andar (18% por veio concluído) e fica ligeiramente mais escasso no segundo (aproximadamente 17,06%). A recarga leva `100 + andar × 10` segundos.

| Disponível a partir do andar | Material novo |
|---:|---|
| 1 | Ferro, cobre e carvão |
| 2 | Prata |
| 3 | Cobalto e obsidiana |
| 10 | Níquel |
| 20 | Titânio |
| 35 | Tungstênio |
| 50 | Cromo |
| 65 | Irídio |
| 80 | Ósmio |
| 95 | Aço do último horizonte |

`Economy.OreChances(andar)` já calcula uma distribuição válida para cada andar de 1 a 100. Isso é uma tabela de expansão; não cria mapas ou disponibiliza materiais de andares ainda inexistentes.

## Lojas

A renovação ocorre em intervalos de 30 minutos pelo relógio do servidor. Cada jogador tem sua própria cota por andar e por janela de tempo. As três categorias iniciais têm comuns básicas sempre disponíveis; as demais opções variam. Não há míticas nos dois primeiros andares nem lendárias na loja de moedas. No terceiro andar, determinadas janelas incluem míticas.

Robux é compra direta de exemplar definido, com raridade máxima lendária. Não vende chance, material para sorteio pago nem ultra lendária. IDs e preços precisam ser configurados pelo proprietário.
