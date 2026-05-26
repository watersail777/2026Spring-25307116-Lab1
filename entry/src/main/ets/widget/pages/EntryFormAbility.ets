import { formBindingData, FormExtensionAbility, formProvider } from '@kit.FormKit'
import { Want } from '@kit.AbilityKit'
import { FallbackData } from '../../data/FallbackData'

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const card = FallbackData.getRandomCard()
    return formBindingData.createFormBindingData({
      title: card.title,
      content: card.content,
      category: card.category,
      cardId: card.id,
      date: new Date().toLocaleDateString()
    })
  }

  onUpdateForm(formId: string): void {
    const card = FallbackData.getRandomCard()
    const data = formBindingData.createFormBindingData({
      title: card.title,
      content: card.content,
      category: card.category,
      cardId: card.id,
      date: new Date().toLocaleDateString()
    })
    formProvider.updateForm(formId, data)
  }
}
