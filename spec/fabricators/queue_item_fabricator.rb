Fabricator(:queue_item) do
  position { (1..100).to_a.sample }
end
