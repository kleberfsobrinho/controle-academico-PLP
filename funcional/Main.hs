module Main where

import Aluno (Aluno)
import qualified Aluno
import Control.Concurrent (threadDelay)
import qualified Controle
import Data.List (delete, sort)
import qualified DataLoader
import qualified DataSaver
import Disciplina (Disciplina)
import qualified Disciplina
import Professor (Professor)
import qualified Professor
import System.Console.ANSI (clearScreen)
import Text.Printf
import qualified Usuario

main :: IO ()
main = do
  putStrLn ("Bem-Vindo(a)!" ++ "\nPara acessar o controle, faça login:\n")
  loginScreen

loginScreen :: IO ()
loginScreen = do
  putStr "Digite sua matrícula: "
  userId <- getLine

  putStr "Digite sua senha: "
  password <- getLine

  usersFile <- DataLoader.readArq "./data/usuarios.csv"
  let availableUsers = DataLoader.loadUsers usersFile

  let authentication = Usuario.authenticates userId password availableUsers
  let authenticated = fst authentication
  let role = snd authentication

  if authenticated
    then do
      putStrLn "\nLogin realizado..."
      threadDelay (10 ^ 6)
      clearScreen
      screen (read userId) role
    else do
      putStr "\nUsuario ou senha invalido! Deseja tentar novamente? (s/n) "
      opcao <- getLine
      if opcao == "s"
        then do
          clearScreen
          loginScreen
        else
          if opcao == "n"
            then do
              putStr "\nSaindo..."
              threadDelay (10 ^ 6)
            else do
              putStr "\nOpção inválida. Saindo do sistema por segurança."
              threadDelay (10 ^ 6)

screen :: Int -> String -> IO ()
screen id role
  | role == "prof" = professorScreen id
  | role == "admin" = adminScreen
  | role == "aluno" = studentScreen id
  | otherwise = putStrLn "Role inválido."

header :: Int -> String -> String
header id name =
  "\n--------------------------\n"
    ++ "Usuário: "
    ++ show id
    ++ " - "
    ++ name

studentScreen :: Int -> IO ()
studentScreen id = do
  studentsFile <- DataLoader.readArq "./data/alunos.csv"
  let students = DataLoader.loadStudents studentsFile
  let student = DataLoader.loadStudent id students

  putStr (studentOptions id (Aluno.name student) ++ "> ")
  option <- getLine
  studentPanel id option

studentOptions :: Int -> String -> String
studentOptions id name =
  header id name ++ 
    "\n\n1) Visualizar disciplinas\n"
    ++ "2) Realizar matrícula\n"
    ++ "3) Cancelar matrícula\n"
    ++ "4) Visualizar média geral\n"
    ++ "(S)air do sistema\n"

studentPanel :: Int -> String -> IO ()
studentPanel id option
  | option == "1" = do 
    Controle.showStudentSubjectsScreen id
    waitUserResponse id studentScreen
  | option == "2" = do
     Controle.enrollSubjectScreen id
     waitUserResponse id studentScreen
  | option == "3" = do 
    Controle.cancelEnrollmentScreen id
    waitUserResponse id studentScreen
  | option == "4" = do
    Controle.totalAverage id
    waitUserResponse id studentScreen
  | option == "S" = do 
    quit
  | otherwise = do 
    putStrLn "opcao invalida"
    waitUserResponse id studentScreen

professorScreen :: Int -> IO ()
professorScreen id = do
  professorsFile <- DataLoader.readArq "./data/professores.csv"
  let professors = DataLoader.loadProfessors professorsFile
  let professor = DataLoader.loadProfessor id professors

  putStr (professorOptions id (Professor.name professor) ++ "> ")
  option <- getLine
  professorPanel id option

professorOptions :: Int -> String -> String
professorOptions id name =
  header id name
    ++ "\n\n1) Visualizar disciplinas\n"
    ++ "2) Registrar aula\n"
    ++ "3) Cadastrar prova\n"
    ++ "4) Situação da classe\n"
    ++ "(S)air do sistema\n"

professorPanel :: Int -> String -> IO ()
professorPanel id option
  | option == "1" = do
    Controle.showProfessorSubjects id
    waitUserResponse id professorScreen
  | option == "2" = do
    Controle.classRegistrationScreen id
    waitUserResponse id professorScreen
  | option == "3" = do 
    Controle.registerTestScreen id
    waitUserResponse id professorScreen
  | option == "4" = do 
    Controle.classSituationScreen id
    waitUserResponse id professorScreen
  | option == "S" = do
    quit
  | otherwise = do
    putStrLn "opcao invalida"
    waitUserResponse id professorScreen

adminScreen :: IO ()
adminScreen = do
  putStr (adminOptions ++ "> ")
  option <- getLine
  adminPanel option

adminOptions :: String
adminOptions =
  header 0 "admin"
    ++ "\n\n1) Cadastrar professor\n"
    ++ "2) Cadastrar aluno\n"
    ++ "3) Cadastrar disciplina\n"
    ++ "4) Associar professor à disciplina\n"
    ++ "5) Listar alunos sem matrículas\n"
    ++ "6) Listar professores sem disciplinas\n"
    ++ "7) Disciplina com a maior média\n"
    ++ "8) Disciplina com a menor média\n"
    ++ "(S)air do sistema\n"
    ++ "Fazer (l)ogoff\n"

adminPanel :: String -> IO ()
adminPanel option
  | option == "1" = do 
    Controle.registrationScreen "professor"
    waitEnterAdmin
  | option == "2" = do
    Controle.registrationScreen "aluno"
    waitEnterAdmin
  | option == "3" = do
    Controle.createSubjectScreen
    waitEnterAdmin
  | option == "4" = do
    Controle.associateTeacherScreen
    waitEnterAdmin
  | option == "5" = do
    Controle.listStudentsWithoutEnrollment
    waitEnterAdmin
  | option == "6" = do 
    Controle.listProfessorWithoutEnrollment
    waitEnterAdmin
  | option == "7" = do 
    Controle.showsSubjectHigherAverage
    waitEnterAdmin
  | option == "8" = do 
    Controle.showsSubjectLowestAverage
    waitEnterAdmin
  | option == "S" = quit
  | otherwise = do 
    putStrLn "opcao invalida"
    waitEnterAdmin

quit :: IO ()
quit = putStrLn "Até a próxima"

waitUserResponse :: Int -> (Int -> IO()) -> IO()
waitUserResponse id screen = do
  putStr "Pressione enter para continuar..."
  x <- getLine
  clearScreen
  screen id

waitEnterAdmin :: IO ()
waitEnterAdmin = do
  putStr "Pressione enter para continuar..."
  x <- getLine
  clearScreen
  adminScreen