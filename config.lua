---config v0.9: Módulo para gerenciamento de arquivos lua de configuração.<br/>
--Facilita o uso de arquivos lua como arquivos de configuração (uma das finalidades
--da linguagem lua), fazendo o carregamento das variáveis definidas
--em um arquivo e criando uma tabela para permitir o acesso centralizado
--a estes dados, além de permitir que a tabela seja salva para atualizar
--o arquivo.<br/><br/>
--O arquivo de configuração deve ter o formato abaixo:<br/>
--variavel1 = valor1<br/>
--variavel2 = valor2<br/>
--@author Manoel Campos da Silva Filho - http://manoelcampos.com
--@license Atribuição-Uso não-comercial-Compartilhamento pela mesma licença http://creativecommons.org/licenses/by-nc-sa/2.5/br/

local _G, print, setfenv, type, io, pairs, loadfile = 
      _G, print, setfenv, type, io, pairs, loadfile
      
module "config"

---Tabela para armazenar as variáveis existentes no arquivo de configuração.
--Pode-se fazer acesso direto para obter ou alterar
--valores de configuração. Mas pode-se usar
--as funções @see getValue ou @see setValue
--O acesso às variáveis do arquivo de configuração
--é feito usando-se config.data.nome_variavel.
--@see load
--@see save
data = {}

--Nome do arquivo de configuração ser ser usado por padrão 
local fileName = "configuration.lua"

--Indica se o arquivo de configuração foi carregado ou não
local loaded = false

---Carrega o arquivo de configuração
--@param _fileName Nome do arquivo a ser carregado.
--O valor padrão é config.lua
--@returns Retorna true em caso de sucesso 
--e false mais uma mensagem de erro em caso de falha
function load(_fileName)
	--Nome do arquivo lua de configuração a ser lido
	fileName = _fileName or fileName

	--Executa o código do arquivo lua contendo as configurações
	local execFile, erro = loadfile(fileName)
	
	if execFile then
	   --Informa que as variáveis globais definidas no arquivo de config
	   --serão criadas dentro da tabela local config
	   setfenv(execFile, data)
	   --Executa o código do arquivo de config, para criar as variáveis 
	   --existentes lá
	   execFile()
	   loaded = true
	   return true
	else
	   return false, erro
	end
end

---Salva o conteúdo da tabela de configuração 
--de volta no arquivo de configuração.
--Função apenas para depuração, pois o módulo io
--não está disponível no Ginga
function save()
	local arq = io.open(fileName, "w+")
	for key, value in pairs(data) do 
	    if type(value) == "string" then
	       value = '"' .. value .. '"'
	    end
	    arq:write(key.." = "..value.."\n")
	end
	arq:close()
end

---Altera o valor de um parâmetro de configuração
--@see save
--@param configParamName Nome do parâmetro no arquivo de configuração,
--carregado na tabela data.
--@param value Valor a ser atribuído ao parâmetro de configuração
--na tabela data
function setValue(configParamName, value)
	data[configParamName] = value 
end

---Obtém o valor de um parâmetro de configuração
--@see load
--@param configParamName Nome do parâmetro no arquivo de configuração,
--carregado na tabela data.
--@param defaultValue Valor padrão a ser retornado,
--caso a variável solicitada não exista.
--@returns Retorna o valordo parâmetro de configuração na tabela data
function getValue(configParamName, defaultValue)
	if data[configParamName] == nil then
	   return defaultValue
	else
	   return data[configParamName]
	end
end
