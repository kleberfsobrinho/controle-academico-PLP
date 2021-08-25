module Main where

import DataLoader (carregaAlunos, carregaProfessores, carregaUsuarios, leArquivo, carregaAluno, carregaProfessor, carregaDisciplina, carregaDisciplinas)
import Professor (Professor, nome, matricula, disciplinasLecionadas, matriculas, newProfessor)
import Disciplina (Disciplina, exibeDisciplina, codigo)
import Aluno (Aluno, nome, matricula, disciplinasMatriculadas, matriculas, newAluno, toStringDisciplinas, mediaTotal, toString)
import DataSaver (salvaAluno, salvaProfessor)
import Usuario (Usuario, autentica)

main :: IO ()
main =
  opcoes

opcoes :: IO ()
opcoes = do
  putStrLn
    ( "1) Fazer login\n"
      ++ "2) Novo usuário? Fazer cadastro\n"
    )

  opcao <- getLine

  putStrLn ""

  if opcao == "1"
    then fazerLogin
    else
      if opcao == "2"
        then fazerCadastro
        else putStrLn "Opção inválida"

fazerLogin :: IO ()
fazerLogin = do
  putStr "Digite sua matrícula: "
  matriculaUsuario <- getLine

  putStr "Digite sua senha: "
  senha <- getLine

  arquivoUsuarios <- leArquivo "./data/usuarios.csv"
  let usuariosDisponiveis = carregaUsuarios arquivoUsuarios

  let autenticacao = Usuario.autentica  matriculaUsuario senha usuariosDisponiveis
  let autenticado = fst autenticacao
  let role = snd autenticacao

  if autenticado
    then tela matriculaUsuario role
    else
      putStrLn
        "Usuario ou senha invalido"

fazerCadastro :: IO ()
fazerCadastro = do
  putStr "(P)rofessor ou (A)luno > "
  opcao <- getLine

  putStr "\nDigite a matrícula: "
  matricula <- getLine

  putStr "Digite o nickname: "
  nick <- getLine

  putStr "Digite seu nome: "
  nome <- getLine

  putStr "Digite sua senha: "
  senha <- getLine

  if opcao == "P"
    then cadastraProfessor matricula nick nome senha
    else cadastraAluno matricula nick nome senha

cadastraProfessor :: String -> String -> String -> String -> IO ()
cadastraProfessor matricula nickname nome senha = do
  arquivoProfessores <- leArquivo "./data/professores.csv"
  let professoresCadastrados = carregaProfessores arquivoProfessores
  let matriculasCadastradas = Professor.matriculas professoresCadastrados

  if read matricula `elem` matriculasCadastradas
    then putStrLn "Professor já cadastrado!"
    else salvaProfessor professor
  where
    professor = newProfessor (read matricula) nome []

cadastraAluno :: String -> String -> String -> String -> IO ()
cadastraAluno matricula nickname nome senha = do
  arquivoAlunos <- leArquivo "./data/alunos.csv"
  let alunosCadastrados = carregaAlunos arquivoAlunos
  let matriculasCadastradas = Aluno.matriculas alunosCadastrados

  if read matricula `elem` matriculasCadastradas
    then putStrLn "Aluno já cadastrado!"
    else salvaAluno aluno
  where
    aluno = newAluno (read matricula) nome []

tela :: String -> String -> IO ()
tela matricula role
  | role == "prof" = telaProf matricula
  | role == "admin" = telaAdmin
  | role == "aluno" = telaAluno matricula
  | otherwise = putStrLn "Role invalido"

telaAluno :: String -> IO ()
telaAluno matricula' = do
  arquivoAlunos <- leArquivo "./data/alunos.csv"
  
  putStrLn (arquivoAlunos !! 1)

  let alunos = DataLoader.carregaAlunos arquivoAlunos
  let aluno = DataLoader.carregaAluno (read matricula') alunos

  putStrLn (
    "\n--------------------------\n"
    ++ "Usuário: "
    ++ show (Aluno.matricula aluno)
    ++ " - "
    ++ Aluno.nome aluno
    ++ "\n\n1) Visualizar disciplinas\n2) Realizar Matricula\n3) Visualizar média geral\n")

  opcao <- getLine

  putStrLn ""

  if opcao == "1"
    then visualizarDisciplinas aluno
    else
      if opcao == "2"
        then realizarMatricula
        else
          if opcao == "3"
            then visualizarMediaGeral
            else putStrLn "Opção inválida"

visualizarDisciplinas :: Aluno -> IO ()
visualizarDisciplinas aluno =
  putStrLn (
        "" 
        ++ show (Aluno.toStringDisciplinas aluno))

realizarMatricula :: IO ()
realizarMatricula = 
  putStrLn "Realizar matrícula..."

visualizarMediaGeral :: IO ()
visualizarMediaGeral = 
  putStrLn "Visualizar média geral..."
  -- putStrLn (
  --       "" 
  --       ++ show (Aluno.toStringDisciplinas aluno))

telaProf :: String -> IO ()
telaProf matricula' = do
  arquivoProfessores <- leArquivo "./data/professores.csv"
  let professores =  DataLoader.carregaProfessores arquivoProfessores
  let professor = DataLoader.carregaProfessor (read matricula') professores

  arquivoDisciplinas <- leArquivo "./data/disciplinas.csv"
  let disciplinas = DataLoader.carregaDisciplinas arquivoDisciplinas

  putStrLn(
    "\n--------------------------\n"
    ++ "Usuário: "
    ++ show(Professor.matricula professor)
    ++ " - "
    ++ Professor.nome professor
    ++ "\n\n1) Visualizar disciplinas\n2) Registrar aula\n3) Cadastrar prova")

  putStr "Qual a opcao selecionada? "
  opcao <- getLine

  if opcao == "1" then putStrLn (exibeDisciplinas (Professor.disciplinasLecionadas professor) disciplinas)
  else putStrLn "Opcao inválida"

getDisciplina :: Int -> [Disciplina] -> String
getDisciplina codigoDisciplina disciplinas = do
  let disciplina = DataLoader.carregaDisciplina codigoDisciplina disciplinas
  Disciplina.exibeDisciplina disciplina ++ "\n"

exibeDisciplinas :: [Int] -> [Disciplina] -> String
exibeDisciplinas _ [] = ""
exibeDisciplinas [] _ = ""
exibeDisciplinas (c : cs) (d : ds) =
  if c == Disciplina.codigo d
    then getDisciplina c (d : ds) ++ exibeDisciplinas cs ds
    else exibeDisciplinas (c:cs) ds


telaAdmin :: IO ()
telaAdmin =
  putStrLn "Tela de admin"
