@dsl @wip
Feature: Export

  Background:
    Given I am logged in

  Scenario: Search form fields
    Given a configuration of:
    """
      class AbAdminProduct < AbAdmin::AbstractResource
        form do
          group :base do
            field :sku
            field :price
          end
          field :is_visible
          field :collection, :as => :association
          locale_tabs do
            field :name
            field :description
          end
        end
      end
      """
    When I am on the new admin product page
    And I fill in the following:
      | Sku                    | t-1          |
      | Price                  | 567          |
      | Display (checkbox)     | check        |
      | product_name_en        | Sofa         |
      | product_description_en | Product desc |
    And I submit form
    Then I should be on the admin products page
    And I should see "Sofa"

  Scenario: Rendering custom form template
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        form :partial => 'admin/products/form_custom'
      end
      """
    And "app/views/admin/products/_form_custom.html.slim" contains:
      """
      = admin_form_for @product do |f|
        = input_set 'My custom fields' do
          = f.input :sku, :label => 'Identifier'

        = f.save_buttons
      """
    When I am on the new admin product page
    And I fill in "Identifier" with "pid-1"
    And I submit form
    Then I should be on the admin products page
    And I should see "pid-1"

  Scenario: Rendering default resource form template
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
      end
      """
    And "app/views/admin/products/_form.html.slim" contains:
      """
      = admin_form_for @product do |f|
        = input_set 'My custom fields' do
          = f.input :sku, :label => 'Identifier'

        = f.save_buttons
      """
    When I am on the new admin product page
    And I fill in "Identifier" with "pid-1"
    And I submit form
    Then I should be on the admin products page
    And I should see "pid-1"
