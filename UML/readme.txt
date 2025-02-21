

여기가 맨 위 부분인데 다이어그램을 만들었으면 startuml 바로 아래에대 skinparam linetype ortho를 꼭 추가해주자
@startuml
skinparam linetype ortho
set namespaceSeparator ::

# ui
dart pub global run dcdg -s lib/ui -o ui.puml

# data
dart pub global run dcdg -s lib/data -o data.puml

# lib
dart pub global run dcdg -s lib -o lib.puml


