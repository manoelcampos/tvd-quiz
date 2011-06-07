---TVD Quiz (script lua principal, responsável
--por desenhar e controlar toda a interface gráfica
--e a interação com o usuário)
--@author Ueslei Taivan - Faculdade Católica do Tocantins
--@author Manoel Campos da Silva Filho  - Instituto Federal de Educação do Tocantins (http://manoelcampos.com) 
--@license Atribuição-Uso não-comercial-Compartilhamento pela mesma licença http://creativecommons.org/licenses/by-nc-sa/2.5/br/

--Carrega o módulo para manipulação do arquivo de dados (dados.lua)
require "config"

---Table principal, contendo os dados e funções
--a serem usados pelo script Lua
local main = {
  --Define o número da pergunta atual, pois a tabela info,
  --definida dentro do arquivo de dados (dados.lua),
  --funciona como um vetor, onde cada posição contém
  --uma determinada informação.
  i = 0, 
  yAlternativa = 45, 
  --Nome do arquivo de Lua das perguntas
  configFile = "perguntas.lua",
  concluido = false
}
  --Variável respostas, que recebe um vetor de respostas digitadas pelo usuário
local respostas = {}

---A partir do número da pergunta, gera uma letra para a mesma (iniciando em A),
--para não confundir com as alternativas, pois estas
--é que são numeradas, para facilitar a escolha pelo controle remoto
function main.letraPergunta(numPergunta)
  return string.char(numPergunta+64)    
end

  --Função responsável por preencher a variável respostas com valores zero,
  --de acordo com o numero de perguntas
function main.iniciaRespostas()
	for i in ipairs(config.data.perguntas) do
		table.insert(respostas, 0) 
  end
end 
---Exibe os botões da aplicação
function main.showButtons()
  --Obtém as dimensões da região do script lua (as dimensões do Canvas)
  local w, h = canvas:attrSize()
  local y = 40
  local bw, bh = 0,0
  local btn = false
  if not main.concluido then
	  btn = canvas:new("media/dir.png")  
	  --Obtém as dimensões do botão
	  bw, bh = btn:attrSize()
	  canvas:compose(w-bw, y, btn)
	
	  btn = canvas:new("media/esq.png")  
	  canvas:compose(w-bw*2, y, btn)
  end

  btn = canvas:new("media/fechar.png")
  --Obtém as dimensões do botão
  bw, bh = btn:attrSize()
  canvas:compose(w-bw, h-(bh+10), btn)
  if not main.concluido then
	  --Adiciona o Botão de concluir, obtém as dimensões e acrescenta na aplicação
	  btn = canvas:new("media/concluir.png")
	  bw, bh = btn:attrSize()
	  canvas:compose(w-(bw+bw+2), h-(bh-5), btn)
  end
  canvas:flush()
end

function main.retangulo()
	  canvas:attrColor("white")
  	  --Obtém as dimensões da região do script lua (as dimensões do Canvas)
      local w, h = canvas:attrSize()
      h = height or h
      canvas:drawRect("fill", 0, 0, w, h)
end

---Avança ou retrocede um índice na tabela info (que funciona como um vetor)
--(definido dentro do arquivo de dados) e em seguida, mostra a info atual.
--@param forward Se true, avança para o próximo índice da tabela info
--senão, retrocede um índice.
function main.showInfo(forward)
  --Se não existe uma variável info,
  --ou a mesma não é uma tabela,
  --ou é não tem nenhum elemento,
  --sai sem fazer nada.
  if config.data.perguntas == nil or type(config.data.perguntas)~="table" or #config.data.perguntas == 0 then
    print("Erro: A tabela de dados não pode ser carregada")
    return
  end

  --Se é pra avançar para o próximo item da tabela info
  if forward == true then
     if main.i == #config.data.perguntas then
        main.i = 1
     else 
        main.i = main.i + 1
     end
  elseif forward == false then --Se é pra voltar um item
     if main.i == 1 then
        main.i = #config.data.perguntas
     else 
        main.i = main.i - 1
     end
  end

  --Posição horizontal e vertical da primeira linha de dados a ser impressa
  local x, y = 10, main.yAlternativa

  main.retangulo() 	
  canvas:attrFont("vera", 28)
  canvas:attrColor("black")

  canvas:drawText(x, 2, main.letraPergunta(main.i)..") "..config.data.perguntas[main.i].per)
  --Pula para a próxima linha, baseado na altura do texto medido com canvas:measureText
  --y = y + th 
  canvas:attrFont("vera", 24)
  canvas:attrColor("blue")
  --Obtém a largura e altura do texto passado por parâmetro.
  --A altura do texto será usada para pular o espaço necessário
  --para desenhar uma nova linha com canvas:drawText
  local tw, th = canvas:measureText("A")
  --Laço de repetição para mostrar as opções na tela, 
  --e se, a opção escolhida for igual ao valor que está armazendada,
  --na tabela respostas, desenha a opção em amarelo, senão
  --desenha em azul.
  for i, resposta in pairs(config.data.perguntas[main.i].resp) do
  	  if i == respostas[main.i] then
  	  canvas:attrColor("yellow")
  	  else 
  	  	canvas:attrColor("blue")
  	  end 	
	  canvas:drawText(x, y, i..") "..resposta)
	  y = y + th 
  end
  
  canvas:flush()
  main.showButtons(true)
end

-- Função que apresenta na tela, quais alternativas
-- Foram acertadas pelo usuário, e quais ele errou...
-- Mostrando o numero da pergunta, o numero da escolha do usuário
-- e o numero da resposta correta, se ele acertar
-- os numeros aparecerão em verde, se ele errar vermelho.
function main.finalizar()
    main.concluido = true 
	main.retangulo()
	local xInicial, yInicial = 20, 10
	local x, y = xInicial, yInicial
	canvas:attrFont("vera", 24)
  	local tw, th = canvas:measureText("A")
  	canvas:attrColor("blue")
  	canvas:drawText(x, y, "Pergunta")
  	--x = x + 30
  	y = y + 30
  	canvas:drawText(x, y, "Escolha")
  	--x = x + 30
  	y = y + 30
  	canvas:drawText(x, y, "Correta")
  	x = 120
  	local acertos = 0
	for i, perg in pairs(config.data.perguntas) do
  	  if respostas[i] == perg.corr then
  	  canvas:attrColor("green")
  	  else 
  	  	canvas:attrColor("red")
  	  end 
  	  x = x + 30	
	  --y = y + th
	  y = yInicial
	  canvas:drawText(x, y, main.letraPergunta(i))
	  --x = x + 30
	  y = y + 30 
	  canvas:drawText(x, y, respostas[i])
	  --x = x + 30
	  y = y + 30
	  canvas:drawText(x, y, perg.corr)
	  if respostas[i] == perg.corr then
	     acertos = acertos + 1
	  end
  end
  x = xInicial  
  y = y + th*2
  canvas:attrFont("vera", 16)
  canvas:attrColor("green")
  local texto = "Verde: Resposta certa " 
  canvas:drawText(x, y, texto)
  tw, th = canvas:measureText(texto)
  canvas:attrColor("red")
  canvas:drawText(x+tw+30, y, "Vermelho: Resposta errada")
  canvas:attrColor("green")
  y = y + th
  local pergs = #config.data.perguntas
  if acertos > 1 then
     texto = " acertos "
  else
     texto = " acerto "
  end
  local percent = acertos*100/pergs
  canvas:drawText(x, y, acertos .. texto.." ("..percent.."%) de "..pergs .. " perguntas")
  canvas:flush()
  main.showButtons(false)
end


---Função tratadora de eventos gerados pelo NCL
--@param evt Table contendo os dados do evento gerado
function main.handler(evt) 
  print(evt.class, evt.type, evt.action, evt.key)
  if evt.class == "ncl" and evt.type == "presentation" and evt.action=="start" then
    --Carrega o arquivo de perguntas, instanciando as variáveis definidas dentro dele,
    --tornando-as acessíveis pelo script atual. Tais variáveis são armazenadas dentro
    --da tabela info, do módulo config, sendo acessadas usando config.data.nome_variavel.
    --No caso do nosso arquivo de perguntas (perguntas.lua), o mesmo só tem uma variável (table)
    --perguntas, assim, para acessá-la, usamos config.data.perguntas.
    config.load(main.configFile) 
    main.iniciaRespostas()
    main.showInfo(true)
    --Aqui trata se o usuário deseja avançar ou retroceder as perguntas
  elseif ((not main.concluido) and evt.class == 'key' and evt.type == 'press') then
    if evt.key == 'CURSOR_LEFT' then
        main.showInfo(false)
    elseif evt.key == 'CURSOR_RIGHT' then
        main.showInfo(true)
    --Tratamento da escolhe da opção pelo usuário, primeiro faz uma busca,
    --para ver se o que foi digitado é do número 1 ao 9...
    --Se o numero existe como opção das perguntas, esse mesmo número é incluso 
    --na tabela de respostas.
    elseif string.find ('123456789', evt.key) then
    	evt.key = tonumber(evt.key)
    	if evt.key ~= nil and evt.key <= #config.data.perguntas[main.i].resp then
	    	local tw, th = canvas:measureText("A")
	    	local y = main.yAlternativa + th * (evt.key - 1)
	    	respostas[main.i] = evt.key
	    	main.showInfo(nil)	
	    	print("Perg ".. main.i,"Resp ".. respostas[main.i],"Escolha ".. evt.key)
    	end 
    end
  elseif evt.class == 'ncl' and evt.type=='attribution' and evt.name=='finalizar' then
      main.finalizar()
  end
end

--Registra a função handler, tratadora de eventos gerados pelo NCL
event.register(main.handler)
