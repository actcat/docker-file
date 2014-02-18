base_container = ARGV[0]
tar_container = "latest.tar"
backup_container = "backup.tar"

# 既にコンテナが存在する場合はバックアップ名のファイルに変更する
if File.exist?(tar_container)
  `sudo rm #{backup_container}` if File.exist?(backup_container)
  `sudo mv #{tar_container} #{backup_container}`
end

# ローカルにコンテナをエクスポートする
`sudo docker export #{base_container} > #{tar_container}`
