# Roteiro de teste no Roblox Studio

Status inicial: testes automatizados de domínio e estrutura disponíveis; este roteiro exige Roblox Studio e ainda não foi executado aqui.

## Primeiro carregamento

- Abra LittleRPG.rbxlx; confira três andares e iluminação no editor e ausência de erros no Output.
- Inicie Play; confirme avatar R6, câmera, animação ao caminhar, arma na mão, HUD e menu M.
- No santuário, vida recupera e ataques não atingem inimigos. Fora dele, um ataque frontal dentro do alcance causa dano; longe, pelas costas ou através de paredes não.
- Examine as cinco famílias de arma: empunhadura, animação, intervalo e alcance. Ajuste `Tool.Grip` se desejar outra orientação artística.
- Inimigos perseguem, avisam o ataque, causam dano, morrem, dão XP e cristais e renascem. Sair da área vermelha evita o dano.
- Jogador derrotado reaparece com equipamento e estado preservados. Cair da ilha deve retornar ao santuário.

## Progressão e menu

- Menu tem exatamente três abas. Eventos não contém atividades fictícias.
- No inventário, alternar mochila/forja permite navegar pelos 50 equipamentos.
- Comprar sem cristais ou nível é rejeitado; comprar duas vezes não duplica débito; equipar item que não possui é rejeitado.
- Nível sobe ao acumular XP, recupera vida e nunca passa de 100.
- Derrote Guardião da Aurora e chegue ao nível 30 para usar o primeiro portal. Derrote Oráculo e chegue ao nível 65 para o segundo. Portais de retorno funcionam.
- Todos os jogadores com contribuição mínima de 5% e próximos recebem recompensa do chefe; jogadores de outro andar ou afastados não.

## Multiplayer e dados

- Em Server & Clients com dois jogadores, confirme que dano, XP, moedas e desbloqueio pertencem ao jogador correto.
- Spam de ataque deve respeitar o intervalo no servidor; troca de arma não elimina esse intervalo.
- Em experiência de teste publicada, adquira um item, saia e entre: nível, XP, cristais, item, arma e andar devem persistir.
- Não habilite acesso do Studio aos dados reais para este teste: sessões do Studio são intencionalmente temporárias.
- Simule falha de carregamento: jogador deve ser desconectado sem gravar um perfil vazio. Verifique avisos de salvamento no Output.
- Teste reconexão rápida: trava de sessão impede dois servidores de escreverem o mesmo perfil ao mesmo tempo. Uma sessão abandonada expira após 180 segundos.

## Dispositivos e arte

- Device Emulator em celular horizontal e vertical: menu inteiro visível, lista rolável, botão de ataque, botão de fechar e controles padrão acessíveis.
- Confirme seleção da UI com mouse/toque; os atalhos Y/R2 são complementares e não equivalem a certificação completa de console.
- Teste modo gráfico leve, FPS e consumo de memória no notebook alvo.
- Importe os WAVs, configure IDs e confirme permissões de áudio. Cheque volumes e repetição ambiente, entrada/saída da camada mecânica no terceiro andar e botão de silenciar.

## Limites da primeira versão

- A IA usa movimento direto e formas ancoradas. Não oferece navegação complexa, animações de combate capturadas ou física de criaturas.
- Salvamento usa UpdateAsync e trava de sessão. Quedas abruptas ainda podem perder o progresso desde o último autosave de 45 segundos.
- As validações de ação no servidor são uma base; proteção completa contra exploração de movimento e testes de carga ficam para uma etapa de produção.
- Todo som depende da importação autorizada para a experiência. Não há IDs públicos arbitrários como substitutos.
