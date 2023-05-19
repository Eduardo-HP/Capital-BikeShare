CREATE TABLE cbs.bikes (
  `duracao_segundos` int DEFAULT NULL,
  `data_inicio` text,
  `data_fim` text,
  `numero_estacao_inicio` int DEFAULT NULL,
  `estacao_inicio` text,
  `numero_estacao_fim` int DEFAULT NULL,
  `estacao_fim` text,
  `numero_bike` text,
  `tipo_membro` text);
  
# Dados carregados via linha de comando
  
SELECT COUNT(*) FROM cbs.bikes;  

# Duração total do aluguel das bikes (em horas)
SELECT SUM(duracao_segundos/60/60) AS duracao_total_horas
FROM cbs.bikes;

# Duração total do aluguel das bikes (em horas), ao longo do tempo (soma acumulada)
SELECT duracao_segundos,
		SUM(duracao_segundos/60/60) OVER (ORDER BY data_inicio) AS duracao_total_horas
FROM cbs.bikes;

# Duração total do aluguel das bikes (em horas), ao longo do tempo, por estação de início do aluguel da bike,
# quando a data de início foi inferior a '2012-01-08'
SELECT estacao_inicio,
		duracao_segundos,
        SUM(duracao_segundos/60/60) OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS tempo_total_horas
FROM cbs.bikes
WHERE data_inicio < '2012-01-08';

# Qual a média de tempo (em horas) de aluguel de bike da estação de início 31017?
SELECT estacao_inicio,
		AVG(duracao_segundos/60/60) AS media_tempo_aluguel
FROM cbs.bikes
where numero_estacao_inicio = 31017
GROUP BY estacao_inicio;

# Qual a média de tempo (em horas) de aluguel da estação de início 31017, ao longo do tempo (média móvel)?
SELECT estacao_inicio,
		AVG(duracao_segundos/60/60) OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS media_movel_aluguel
FROM cbs.bikes
WHERE numero_estacao_inicio = 31017;

#Retornando
# Estação de início, data de início e duração de cada aluguel de bike em segundos
# Duração total de aluguel das bikes ao longo do tempo por estação de início
# Duração média do aluguel de bikes ao longo do tempo por estação de início
# Número de aluguéis de bikes por estação ao longo do tempo 
# Somente os registros quando a data de início for inferior a '2012-01-08'

SELECT estacao_inicio,
       data_inicio,
       duracao_segundos,
       SUM(duracao_segundos/60/60) OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS duracao_total_aluguel,
       AVG(duracao_segundos/60/60) OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS media_tempo_aluguel,
       COUNT(duracao_segundos/60/60) OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS numero_alugueis
FROM cbs.bikes
WHERE data_inicio < '2012-01-08';

# Retornando
# Estação de início, data de início de cada aluguel de bike e duração de cada aluguel em segundos
# Número de aluguéis de bikes (independente da estação) ao longo do tempo 
# Somente os registros quando a data de início for inferior a '2012-01-08'

SELECT estacao_inicio,
		data_inicio,
		duracao_segundos,
        COUNT(duracao_segundos/60/60) OVER (ORDER BY data_inicio) AS numero_alugueis
FROM cbs.bikes
WHERE data_inicio < '2012-01-08';

# Estação, data de início, duração em segundos do aluguel e número de aluguéis ao longo do tempo
SELECT estacao_inicio,
       data_inicio,
       duracao_segundos,
       ROW_NUMBER() OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS numero_alugueis
FROM cbs.bikes
WHERE data_inicio < '2012-01-08';

# Estação, data de início, duração em segundos do aluguel e número de aluguéis ao longo do tempo
# para a estação de id 31000
SELECT estacao_inicio,
       data_inicio,
       duracao_segundos,
       ROW_NUMBER() OVER (PARTITION BY estacao_inicio ORDER BY data_inicio) AS numero_alugueis
FROM cbs.bikes
WHERE data_inicio < '2012-01-08'
AND numero_estacao_inicio = 31000;

# Estação, data de início, duração em segundos do aluguel e número de aluguéis ao longo do tempo
# para a estação de id 31000, com a coluna de data_inicio convertida para o formato date

SELECT estacao_inicio,
		CAST(data_inicio as date) AS data_inicio,
        duracao_segundos,
        ROW_NUMBER() OVER (PARTITION BY estacao_inicio ORDER BY CAST(data_inicio as date)) AS numero_alugueis
FROM cbs.bikes
WHERE data_inicio < '2012-01-08'
AND numero_estacao_inicio = 31000;

# Qual a diferença da duração do aluguel de bikes ao longo do tempo, de um registro para outro?
SELECT estacao_inicio,
		CAST(data_inicio as date) AS data_inicio,
       duracao_segundos,
       duracao_segundos - LAG(duracao_segundos, 1) OVER (PARTITION BY estacao_inicio ORDER BY CAST(data_inicio as date)) AS diferenca
FROM cbs.bikes
WHERE data_inicio < '2012-01-08'
AND numero_estacao_inicio = 31000;

# Sem valoar 'null'
SELECT *
  FROM (
    SELECT estacao_inicio,
           CAST(data_inicio as date) AS data_inicio,
           duracao_segundos,
           duracao_segundos - LAG(duracao_segundos, 1) OVER (PARTITION BY estacao_inicio ORDER BY CAST(data_inicio as date)) AS diferenca
      FROM cbs.bikes
     WHERE data_inicio < '2012-01-08'
     AND numero_estacao_inicio = 31000) resultado
 WHERE resultado.diferenca IS NOT NULL;
 
 # Manipulação de datas
 
 # Extraindo itens específicos da data
 SELECT data_inicio,
		DATE(data_inicio),
        TIMESTAMP(data_inicio),
        YEAR(data_inicio),
        MONTH(data_inicio),
        DAY(data_inicio)
FROM cbs.bikes
WHERE numero_estacao_inicio = 31000;

# Extraindo o mês da data
SELECT EXTRACT(MONTH FROM data_inicio) AS mes, duracao_segundos
FROM cbs.bikes
WHERE numero_estacao_inicio = 31000;

# Adicionando 10 dias à data de início
SELECT data_inicio, DATE_ADD(data_inicio, INTERVAL 10 DAY) AS data_inicio, duracao_segundos
FROM cbs.bikes
WHERE numero_estacao_inicio = 31000;

# Retornando dados de 10 dias anteriores à data de início do aluguel da bike
SELECT data_inicio, duracao_segundos
FROM cbs.bikes
WHERE DATE_SUB("2012-03-31", INTERVAL 10 DAY) <= data_inicio
AND numero_estacao_inicio = 31000;