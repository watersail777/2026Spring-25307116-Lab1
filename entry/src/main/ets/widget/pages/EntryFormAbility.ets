import { formBindingData, FormExtensionAbility, formProvider } from '@kit.FormKit'
import { Want } from '@kit.AbilityKit'
import { LocalStore } from '../../data/LocalStore'

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const queries = LocalStore.getRecentQueries()
    return formBindingData.createFormBindingData({
      'query1': queries.length > 0 ? queries[0] : '暂无查询',
      'query2': queries.length > 1 ? queries[1] : '',
      'query3': queries.length > 2 ? queries[2] : ''
    })
  }

  onUpdateForm(formId: string): void {
    const queries = LocalStore.getRecentQueries()
    const data = formBindingData.createFormBindingData({
      'query1': queries.length > 0 ? queries[0] : '暂无查询',
      'query2': queries.length > 1 ? queries[1] : '',
      'query3': queries.length > 2 ? queries[2] : ''
    })
    formProvider.updateForm(formId, data)
  }
}