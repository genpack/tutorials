data aws_dynamodb_table repo_buildproject_mapping {
  name = "RepositoryToBuildProjectMapping"
}


resource aws_dynamodb_table_item repository_project_mapping {
  table_name = data.aws_dynamodb_table.repo_buildproject_mapping.name

  hash_key = "codecommit_repository"
  item = jsonencode(
    {
      codecommit_repository : {
        S : data.aws_codecommit_repository.repository.repository_name
      }
      codebuild_project : {
        S : aws_codebuild_project.build.name
      }
    }
  )
}
