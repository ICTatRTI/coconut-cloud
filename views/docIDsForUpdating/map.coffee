(doc) ->
  emit(doc._id, null) if doc.collection is "user" or doc.collection is "question"
  if doc.isApplicationDoc is true
    emit(doc._id, null)
